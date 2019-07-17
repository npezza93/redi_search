# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    class TextFieldTest < Minitest::Test
      def test_default_options
        schema = RediSearch::Schema::TextField.new("temp_field")
        assert_equal ["temp_field", "TEXT", "WEIGHT", 1.0], schema.to_a
      end

      def test_sortable_option
        schema = RediSearch::Schema::TextField.new(
          "temp_field", sortable: true
        )
        assert_equal(
          ["temp_field", "TEXT", "SORTABLE", "WEIGHT", 1.0], schema.to_a
        )
      end

      def test_no_index_option
        schema = RediSearch::Schema::TextField.new(
          "temp_field", no_index: true
        )
        assert_equal(
          ["temp_field", "TEXT", "NOINDEX", "WEIGHT", 1.0], schema.to_a
        )
      end

      def test_no_stem_option
        schema = RediSearch::Schema::TextField.new(
          "temp_field", no_stem: true
        )
        assert_equal(
          ["temp_field", "TEXT", "NOSTEM", "WEIGHT", 1.0], schema.to_a
        )
      end

      def test_phonetic_option
        schema = RediSearch::Schema::TextField.new(
          "temp_field", phonetic: "fg"
        )
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "PHONETIC", "fg"], schema.to_a
        )
      end

      def test_all_options
        schema = RediSearch::Schema::TextField.new(
          "temp_field", no_index: true, sortable: true, no_stem: true,
                        weight: 2.0, phonetic: "fg"
        )
        assert_equal(
          ["temp_field", "TEXT", "SORTABLE", "NOINDEX", "NOSTEM", "WEIGHT",
           2.0, "PHONETIC", "fg"],
          schema.to_a
        )
      end
    end
  end
end
