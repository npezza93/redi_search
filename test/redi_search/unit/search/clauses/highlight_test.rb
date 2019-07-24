# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/clauses/highlight"

module RediSearch
  class Search
    module Clauses
      class HighlightTest < Minitest::Test
        def setup
          @clause = Highlight
        end

        def test_returns_highlight_keyword
          assert_equal ["HIGHLIGHT", "TAGS", "<b>", "</b>"], @clause.new.clause
        end

        def test_tags_clause
          assert_equal(
            ["HIGHLIGHT", "TAGS", "<i>", "</i>"],
            @clause.new(opening_tag: "<i>", closing_tag: "</i>").clause
          )
        end

        def test_tags_with_no_opening
          assert_raises ArgumentError do
            @clause.new(opening_tag: nil).clause
          end
        end

        def test_tags_with_no_closing
          assert_raises ArgumentError do
            @clause.new(closing_tag: nil).clause
          end
        end

        def test_fields_clause
          assert_equal(
            ["HIGHLIGHT", "FIELDS", 1, ["name"], "TAGS", "<b>", "</b>"],
            @clause.new(fields: ["name"]).clause
          )
        end

        def test_fields_is_always_before_tags
          assert_equal(
            ["HIGHLIGHT", "FIELDS", 1, ["name"], "TAGS", "<b>", "</b>"],
            @clause.new(
              fields: ["name"], opening_tag: "<b>", closing_tag: "</b>"
            ).clause
          )
        end
      end
    end
  end
end
