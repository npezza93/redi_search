# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class WithScoresTest < Minitest::Test
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
          documents = @searcher.with_scores.load

          assert_respond_to documents.first, :score
        end
      end
    end
  end
end
