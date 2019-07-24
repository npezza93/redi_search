# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class SortByTest < Minitest::Test
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
          assert @searcher.sort_by(:first).load
        end

        def test_clause_with_desc_order
          assert @searcher.sort_by(:first, order: :desc).load
        end
      end
    end
  end
end
