# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class SlopTest < Minitest::Test
        def setup
          @index = Index.new(:user) do
            text_field :first
            text_field :last
          end.tap(&:create)

          @index.add(Document.new(@index, 1, first: :foo, last: :bar))
          @searcher = Search.new(@index, "foo")
        end

        def teardown
          @index.drop
        end

        def test_clause
          assert @searcher.slop(1).load
        end
      end
    end
  end
end
