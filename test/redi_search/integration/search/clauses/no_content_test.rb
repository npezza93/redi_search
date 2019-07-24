# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class NoContentTest < Minitest::Test
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
          document = @searcher.no_content.load.first
          refute_respond_to document, :first
          refute_respond_to document, :middle
          refute_respond_to document, :last
          assert_respond_to document, :document_id
        end
      end
    end
  end
end
