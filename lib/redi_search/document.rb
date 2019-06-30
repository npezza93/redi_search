# frozen_string_literal: true

module RediSearch
  class Document
    class << self
      def for_object(index, record, serializer: nil)
        object_to_serialize =
          if serializer
            serializer.new(record)
          else
            record
          end

        field_values = index.schema.fields.map do |field|
          [field.to_s, object_to_serialize.public_send(field)]
        end.to_h

        new(index, object_to_serialize.id, field_values)
      end

      def get(index, document_id)
        response = RediSearch.client.call!(
          "GET", index.name, prepend_document_id(index, document_id)
        )

        return if response.blank?

        new(index, document_id, Hash[*response])
      end

      def mget(index, *document_ids)
        unique_document_ids = document_ids.map do |id|
          prepend_document_id(index, id)
        end
        document_ids.zip(
          RediSearch.client.call!("MGET", index.name, *unique_document_ids)
        ).map do |document|
          next if document[1].blank?

          new(index, document[0], Hash[*document[1]])
        end.compact
      end

      def prepend_document_id(index, document_id)
        if document_id.to_s.starts_with? index.name
          document_id
        else
          "#{index.name}#{document_id}"
        end
      end
    end

    attr_reader :attributes, :score

    def initialize(index, document_id, fields, score = nil)
      @index = index
      @document_id = document_id
      @attributes = fields
      @score = score

      attributes.each do |field, value|
        next unless schema_fields.include? field

        instance_variable_set(:"@#{field}", value)
        define_singleton_method(field) { value }
      end
    end

    def del
      client.call!("DEL", index.name, document_id).ok?
    end

    #:nocov:
    def pretty_print(printer) # rubocop:disable Metrics/MethodLength
      printer.object_address_group(self) do
        printer.seplist(
          pretty_print_attributes , proc { printer.text "," }
        ) do |field_name|
          printer.breakable " "
          printer.group(1) do
            printer.text field_name
            printer.text ":"
            printer.breakable
            printer.pp public_send(field_name)
          end
        end
      end
    end

    def pretty_print_attributes
      pp_attrs = attributes.keys.dup
      pp_attrs.push("document_id")
      pp_attrs.push("score") if score.present?

      pp_attrs.compact
    end
    #:nocov:

    def schema_fields
      @schema_fields ||= index.schema.fields.map(&:to_s)
    end

    def redis_attributes
      attributes.to_a.flatten
    end

    def document_id
      self.class.prepend_document_id(index, @document_id)
    end

    def document_id_without_index
      if @document_id.to_s.starts_with? index.name
        @document_id.gsub(index.name, "")
      else
        @document_id
      end
    end

    private

    attr_reader :index

    def client
      RediSearch.client
    end
  end
end
