# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/clauses/highlight"

module RediSearch
  class Search
    module Clauses
      class HighlightTest < Minitest::Test
        def setup
          @index = Index.new(:user, first: :text, last: :text, middle: :text)
          @index.create
          @index.add(Document.new(
            @index, 1, first: :foo, last: :bar, middle: :baz
          ))
          @searcher = Search.new(@index, "foo")
        end

        def teardown
          @index.drop
        end

        def test_clause
          document = @searcher.highlight(fields: %i(first last)).load.first
          assert_includes document.first, "<b>"
          assert_includes document.first, "</b>"
        end

        def test_clause_with_different_tags
          document = @searcher.highlight(
            fields: %i(first last), opening_tag: "tt", closing_tag: "td"
          ).load.first
          assert_includes document.first, "tt"
          assert_includes document.first, "td"
        end
      end
    end
  end
end
