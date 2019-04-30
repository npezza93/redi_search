# frozen_string_literal: true

module RediSearch
  class Document
    class << self
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

      schema_fields.each do |field|
        instance_variable_set(:"@#{field}", fields[field])
        define_singleton_method field do
          fields[field]
        end
      end
    end

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

    private

    attr_reader :index

    def schema_fields
      @schema_fields ||= index.schema.fields.map(&:to_s)
    end
  end
end
