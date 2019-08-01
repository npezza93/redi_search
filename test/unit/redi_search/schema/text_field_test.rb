# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    class TextFieldTest < Minitest::Test
      def test_default_options
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0],
          TextField.new("temp_field").to_a
        )
      end

      def test_sortable_option
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "SORTABLE"],
          TextField.new("temp_field", sortable: true).to_a
        )
      end

      def test_no_index_option
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "NOINDEX"],
          TextField.new("temp_field", no_index: true).to_a
        )
      end

      def test_no_stem_option
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "NOSTEM"],
          TextField.new("temp_field", no_stem: true).to_a
        )
      end

      def test_phonetic_option
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "PHONETIC", "fg"],
          TextField.new("temp_field", phonetic: "fg").to_a
        )
      end

      def test_all_options # rubocop:disable Metrics/MethodLength
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 2.0, "PHONETIC", "fg", "SORTABLE",
           "NOINDEX", "NOSTEM"],
          TextField.new("temp_field", no_index: true, sortable: true,
                                      no_stem: true, weight: 2.0,
                                      phonetic: "fg").to_a
        )
      end
    end
  end
end
