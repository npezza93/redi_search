# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/numeric_field"

module RediSearch
  class Schema
    class NumericFieldTest < Minitest::Test
      def test_default_options
        schema = RediSearch::Schema::NumericField.new("temp_field")
        assert_equal %w(temp_field NUMERIC), schema.to_a
      end

      def test_sortable_option
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", sortable: true
        )
        assert_equal %w(temp_field NUMERIC SORTABLE), schema.to_a
      end

      def test_no_index_option
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", no_index: true
        )
        assert_equal %w(temp_field NUMERIC NOINDEX), schema.to_a
      end

      def test_both_options
        schema = RediSearch::Schema::NumericField.new(
          "temp_field", no_index: true, sortable: true
        )
        assert_equal %w(temp_field NUMERIC SORTABLE NOINDEX), schema.to_a
      end
    end
  end
end
