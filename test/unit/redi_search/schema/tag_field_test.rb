# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Schema
    class TagFieldTest < Minitest::Test
      def test_default_options
        schema = TagField.new("temp_field")
        assert_equal %w(temp_field TAG SEPARATOR ,), schema.to_a
      end

      def test_sortable_option
        schema = TagField.new("temp_field", sortable: true)
        assert_equal %w(temp_field TAG SEPARATOR , SORTABLE), schema.to_a
      end

      def test_no_index_option
        schema = TagField.new("temp_field", no_index: true)
        assert_equal %w(temp_field TAG SEPARATOR , NOINDEX), schema.to_a
      end

      def test_separator_option
        schema = TagField.new("temp_field", separator: ",")
        assert_equal %w(temp_field TAG SEPARATOR ,), schema.to_a
      end

      def test_all_options
        schema = TagField.new(
          "temp_field", no_index: true, sortable: true, separator: ","
        )
        assert_equal(
          %w(temp_field TAG SEPARATOR , SORTABLE NOINDEX), schema.to_a
        )
      end
    end
  end
end
