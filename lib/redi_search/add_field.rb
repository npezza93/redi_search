# frozen_string_literal: true

module RediSearch
  class AddField
    def initialize(index, field_name, schema)
      @index = index
      @field_name = field_name
      @raw_schema = schema
    end

    def call!
      index.schema.add_field(field_name, raw_schema)

      RediSearch.client.call!(*command).ok?
    end

    def call
      call!
    rescue Redis::CommandError
      false
    end

    private

    attr_reader :index, :field_name, :raw_schema

    def command
      ["ALTER", index.name, "SCHEMA", "ADD", *field_schema]
    end

    def field_schema
      @field_schema ||= Schema.make_field(field_name, raw_schema)
    end
  end
end
