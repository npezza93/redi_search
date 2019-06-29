# frozen_string_literal: true

module RediSearch
  class Alter
    def initialize(index, field_name, schema)
      @index = index
      @field_name = field_name
      @raw_schema = schema
    end

    def call!
      index.schema.alter(field_name, raw_schema)
      RediSearch.client.call!(
        "ALTER",
        index.name,
        "SCHEMA",
        "ADD",
        *field_schema
      ).ok?
    end

    private

    attr_reader :index, :field_name, :raw_schema

    def field_schema
      @field_schema ||= Schema.make_field(field_name, raw_schema)
    end
  end
end
