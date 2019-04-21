# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/numeric_field"

module RediSearch
  class Schema
    class NumericFieldTest < ActiveSupport::TestCase
      test "default options" do
        schema = RediSearch::Schema::NumericField.new("temp_field")
        assert_equal %w(temp_field NUMERIC), schema.to_a
      end

      test "sortable option" do
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", sortable: true
        )
        assert_equal %w(temp_field NUMERIC SORTABLE), schema.to_a
      end

      test "no_index option" do
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", no_index: true
        )
        assert_equal %w(temp_field NUMERIC NOINDEX), schema.to_a
      end

      test "both options" do
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", no_index: true, sortable: true
        )
        assert_equal %w(temp_field NUMERIC SORTABLE NOINDEX), schema.to_a
      end
    end
  end
end
