# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class NoStopWordsTest < Minitest::Test
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
          assert @searcher.no_stop_words.load
        end
      end
    end
  end
end
