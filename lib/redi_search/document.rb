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
        response = RediSearch.client.call!("GET", index.name, document_id)

        return if response.blank?

        new(index, document_id, Hash[*response])
      end

      def mget(index, *document_ids)
        document_ids.zip(
          RediSearch.client.call!("MGET", index.name, *document_ids)
        ).map do |document|
          next if document[1].blank?

          new(index, document[0], Hash[*document[1]])
        end.compact
      end
    end

    attr_reader :document_id

    def initialize(index, document_id, fields)
      @index = index
      @document_id = document_id
      @to_a = []

      schema_fields.each do |field|
        @to_a.push([field, fields[field]])
        instance_variable_set(:"@#{field}", fields[field])
        define_singleton_method field do
          fields[field]
        end
      end
    end

    def del
      client.call!("DEL", index.name, document_id).ok?
    end

    #:nocov:
    def pretty_print(printer) # rubocop:disable Metrics/MethodLength
      printer.object_address_group(self) do
        printer.seplist(
          schema_fields.append("document_id"), proc { printer.text "," }
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
    #:nocov:

    def schema_fields
      @schema_fields ||= index.schema.fields.map(&:to_s)
    end

    def to_a
      @to_a.flatten
    end

    private

    attr_reader :index

    def client
      RediSearch.client
    end
  end
end
