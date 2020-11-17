# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class ReturnTest < Minitest::Test
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
          documents = @searcher.return(:first, :middle).load

          assert_equal 1, documents.size
          %i(first middle).each do |method|
            assert_respond_to documents.first, method
          end
          refute_respond_to documents.first, :last
        end
      end
    end
  end
end
