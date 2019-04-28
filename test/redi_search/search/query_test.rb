# frozen_string_literal: true

require "test_helper"
require "redi_search/search/query"

module RediSearch
  module Search
    class QueryTest < ActiveSupport::TestCase
      setup do
        @index = Index.new("user_idx", name: :text)
        @index.drop
        @index.create
      end

      teardown do
        @index.drop
      end

      test "query execution" do
        query = RediSearch::Search::Query.new(@index, "dr")
        assert_equal RediSearch::Result::Collection, query.to_a.class
      end

      test "highlight command" do
        query = RediSearch::Search::Query.new(@index, "dr")

        assert_equal %w(SEARCH user_idx dr HIGHLIGHT), query.highlight.command
      end

      test "highlight command with tags" do
        query = RediSearch::Search::Query.new(@index, "dr")

        assert_equal(
          %w(SEARCH user_idx dr HIGHLIGHT TAGS b bb),
          query.highlight(tags: { open: "b", close: "bb" }).command
        )
      end

      test "slop clause" do
        query = RediSearch::Search::Query.new(@index, "dr")

        assert_equal(
          ["SEARCH", "user_idx", "dr", "SLOP", 1], query.slop(1).command
        )
      end
    end
  end
end
