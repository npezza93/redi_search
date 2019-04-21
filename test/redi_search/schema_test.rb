# frozen_string_literal: true

require "test_helper"
require "redi_search/schema"

module RediSearch
  class SchemaTest < ActiveSupport::TestCase
    test "#to_s" do
      schema = <<~SCHEMA.squish
        name TEXT SORTABLE WEIGHT 1.0 age NUMERIC SORTABLE myTag TAG
        SORTABLE other TEXT WEIGHT 1.0
      SCHEMA

      assert_equal(
        schema,
        RediSearch::Schema.new({
          name: { text: { sortable: true } },
          age: { numeric: { sortable: true } },
          myTag: { tag: { sortable: true } },
          other: :text
        }).to_s
      )
    end
  end
end
