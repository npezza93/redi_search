# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class HighlightTest < Minitest::Test
        def setup
          @index = Index.new(:user) do
            text_field :first
          end.tap(&:create)

          @index.add(Document.new(@index, 1, first: :foo))
          @searcher = Search.new(@index, "foo")
        end

        def teardown
          @index.drop
        end

        def test_clause
          document = @searcher.highlight(fields: %i(first)).load.first
          assert_includes document.first, "<b>"
          assert_includes document.first, "</b>"
        end

        def test_clause_with_different_tags
          document = @searcher.highlight(
            fields: %i(first), opening_tag: "tt", closing_tag: "td"
          ).load.first
          assert_includes document.first, "tt"
          assert_includes document.first, "td"
        end
      end
    end
  end
end
