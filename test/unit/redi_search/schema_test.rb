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
      assert_equal(%i(name age myTag other), actual_schema.fields)
    end

    private

    def actual_schema
      Schema.new({
        name: { text: { sortable: true } },
        age: { numeric: { sortable: true } },
        myTag: { tag: { sortable: true } },
        other: :text
      })
    end
  end
end
