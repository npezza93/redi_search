# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Schema
    class NumericFieldTest < Minitest::Test
      def test_default_options
        assert_equal(
          %w(temp_field NUMERIC),
          NumericField.new("temp_field").to_a
        )
      end

      def test_sortable_option
        assert_equal(
          %w(temp_field NUMERIC SORTABLE),
          NumericField.new("temp_field", sortable: true).to_a
        )
      end

      def test_no_index_option
        assert_equal(
          %w(temp_field NUMERIC NOINDEX),
          NumericField.new("temp_field", no_index: true).to_a
        )
      end

      def test_both_options
        assert_equal(
          %w(temp_field NUMERIC SORTABLE NOINDEX),
          NumericField.new("temp_field", no_index: true, sortable: true).to_a
        )
      end
    end
  end
end
