# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    class TextFieldTest < ActiveSupport::TestCase
      test "default options" do
        schema = RediSearch::Schema::TextField.new("temp_field")
        assert_equal ["temp_field", "TEXT", "WEIGHT", 1.0], schema.to_a
      end

      test "sortable option" do
        schema = RediSearch::Schema::TextField.new(
          "temp_field", sortable: true
        )
        assert_equal(
          ["temp_field", "TEXT", "SORTABLE", "WEIGHT", 1.0], schema.to_a
        )
      end

      test "no_index option" do
        schema = RediSearch::Schema::TextField.new(
          "temp_field", no_index: true
        )
        assert_equal(
          ["temp_field", "TEXT", "NOINDEX", "WEIGHT", 1.0], schema.to_a
        )
      end

      test "no_stem option" do
        schema = RediSearch::Schema::TextField.new(
          "temp_field", no_stem: true
        )
        assert_equal(
          ["temp_field", "TEXT", "NOSTEM", "WEIGHT", 1.0], schema.to_a
        )
      end

      test "phonetic option" do
        schema = RediSearch::Schema::TextField.new(
          "temp_field", phonetic: "fg"
        )
        assert_equal(
          ["temp_field", "TEXT", "WEIGHT", 1.0, "PHONETIC", "fg"], schema.to_a
        )
      end

      test "all options" do
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
