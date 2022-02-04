# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class NoContentTest < Minitest::Test
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
          document = searcher.no_content.load.first
          %i(first).each do |method|
            refute_respond_to document, method
          end
          assert_respond_to document, :document_id
        end

        private

        def searcher
          Search.new(@index, "foo")
        end
      end
    end
  end
end
