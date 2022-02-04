# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SchemaTest < Minitest::Test
    def test_to_a
      schema = [
        "name", "TEXT", "WEIGHT", 1.0, "SORTABLE", "age", "NUMERIC",
        "SORTABLE", "myTag", "TAG", "SEPARATOR", ",", "SORTABLE",
        "other", "TEXT", "WEIGHT", 1.0
      ]

      assert_equal(schema, actual_schema.to_a)
    end

    def test_fields
      assert_equal(%i(name age myTag other), actual_schema.fields.map(&:name))
    end

    private

    def actual_schema
      Schema.new do
        text_field :name, sortable: true
        numeric_field :age, sortable: true
        tag_field :myTag, sortable: true
        text_field :other
      end
    end
  end
end
