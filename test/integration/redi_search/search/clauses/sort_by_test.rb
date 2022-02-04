# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class SortByTest < Minitest::Test
        def setup
          @index = Index.new(:users) do
            text_field :first, sortable: true
            text_field :last
          end.tap(&:create!)

          assert @index.add(Document.new(@index, 1, first: :foo, last: :bar))
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
