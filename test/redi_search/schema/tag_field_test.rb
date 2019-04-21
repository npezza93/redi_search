# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/tag_field"

module RediSearch
  class Schema
    class TagFieldTest < ActiveSupport::TestCase
      test "default options" do
        schema = RediSearch::Schema::TagField.new("temp_field")
        assert_equal "temp_field TAG", schema.to_s
      end

      test "sortable option" do
        schema = RediSearch::Schema::TagField.new(
          "temp_field", sortable: true
        )
        assert_equal "temp_field TAG SORTABLE", schema.to_s
      end

      test "no_index option" do
        schema = RediSearch::Schema::TagField.new(
          "temp_field", no_index: true
        )
        assert_equal "temp_field TAG NOINDEX", schema.to_s
      end

      test "separator option" do
        schema = RediSearch::Schema::TagField.new(
          "temp_field", separator: ","
        )
        assert_equal "temp_field TAG SEPARATOR ,", schema.to_s
      end

      test "all options" do
        schema = RediSearch::Schema::TagField.new(
          "temp_field", no_index: true, sortable: true, separator: ","
        )
        assert_equal "temp_field TAG SORTABLE NOINDEX SEPARATOR ,", schema.to_s
      end
    end
  end
end
