# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class LimitTest < Minitest::Test
        def setup
          @index = Index.new(:user) do
            text_field :first
          end.tap(&:create)

          @index.add(Document.new(@index, 1, first: :foo))
        end

        def teardown
          @index.drop
        end

        def test_clause
          assert searcher.limit(1).load
        end

        def test_clause_with_offset
          assert searcher.limit(10, 10).load
        end

        private

        def searcher
          Search.new(@index, "foo")
        end
      end
    end
  end
end
