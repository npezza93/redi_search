# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class SearchTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("user_idx", name: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "query execution" do
      query = RediSearch::Search.new(@index, "dr")
      assert_equal RediSearch::Result::Collection, query.to_a.class
    end

    test "highlight command" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal "SEARCH user_idx `dr` HIGHLIGHT", query.highlight.to_redis
    end

    test "highlight command with tags" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` HIGHLIGHT TAGS b bb",
        query.highlight(tags: { open: "b", close: "bb" }).to_redis
      )
    end

    test "slop clause" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` SLOP 1", query.slop(1).to_redis
      )
    end

    test "terms with options" do
      query = User.search(hello: { fuzziness: 1 })

      assert_equal(
        "SEARCH user_idx `%hello%`", query.to_redis
      )
    end

    test "simple phrase" do
      query = User.search("hello", "world")

      assert_equal(
        "SEARCH user_idx \"(`hello` `world`)\"", query.to_redis
      )
    end

    test "exact phrase" do
      query = User.search("hello world")

      assert_equal(
        "SEARCH user_idx \"`hello world`\"", query.to_redis
      )
    end
  end
end
