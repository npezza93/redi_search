# frozen_string_literal: true

module RediSearch
  class Document
    class Converter
      def initialize(index, record)
        @index = index
        @record = record
      end

      def document
        Document.new(
          index,
          record.id,
          index.schema.fields.map do |field|
            [field.to_s, record.public_send(field)]
          end.to_h
        )
      end

      private

      attr_reader :index, :record
    end
  end
end
