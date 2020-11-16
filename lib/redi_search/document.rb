# frozen_string_literal: true

require "redi_search/document/display"
require "redi_search/document/finder"

module RediSearch
  class Document
    include Display

    class << self
      def for_object(index, record, serializer: nil)
        object_to_serialize = serializer&.new(record) || record

        field_values = index.schema.fields.map do |field|
          [field.to_s, object_to_serialize.public_send(field)]
        end.compact.to_h

        new(index, object_to_serialize.id, field_values)
      end

      def get(index, document_id)
        Finder.new(index, document_id).find
      end

      def mget(index, *document_ids)
        Finder.new(index, *document_ids).find
      end
    end

    attr_reader :attributes, :score

    def initialize(index, document_id, fields, score = nil)
      @index = index
      @document_id = document_id
      @attributes = fields
      @score = score

      load_attributes
    end

    def del
      RediSearch.client.call!("DEL", document_id, skip_ft: true).ok?
    end

    def schema_fields
      @schema_fields ||= index.schema.fields.map(&:to_s)
    end

    def redis_attributes
      attributes.to_a.flatten
    end

    def document_id
      if @document_id.to_s.start_with? index.name
        @document_id
      else
        "#{index.name}#{@document_id}"
      end
    end

    def document_id_without_index
      if @document_id.to_s.start_with? index.name
        @document_id.gsub(index.name, "")
      else
        @document_id
      end
    end

    private

    attr_reader :index

    def load_attributes
      attributes.each do |field, value|
        next unless schema_fields.include? field.to_s

        instance_variable_set(:"@#{field}", value)
        define_singleton_method(field) { value }
      end
    end
  end
end
