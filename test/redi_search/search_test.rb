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

    test "#in_order clause" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` INORDER", query.in_order.to_redis
      )
    end

    test "#language clause" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` LANGUAGE danish",
        query.language("danish").to_redis
      )
    end

    test "#sort_by clause" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` SORTBY first asc",
        query.sort_by(:first).to_redis
      )
    end

    test "#sort_by desc clause" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_equal(
        "SEARCH user_idx `dr` SORTBY first desc",
        query.sort_by(:first, order: :desc).to_redis
      )
    end

    test "#sort_by arg error with bad order" do
      query = RediSearch::Search.new(@index, nil, "dr")

      assert_raise ArgumentError do
        query.sort_by(:first, order: :random)
      end
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

    test "or phrase" do
      query = User.search("hello").or "world"

      assert_equal(
        "SEARCH user_idx \"`hello`|`world`\"", query.to_redis
      )
    end

    # test "and not phrase" do
    #   query = User.search("hello").and.not "world"
    #
    #   assert_equal(
    #     "SEARCH user_idx \"`hello` -`world`\"", query.to_redis
    #   )
    # end
    #
    # test "and not multiple phrase" do
    #   query = User.search("hello").and.not "world", "werld"
    #
    #   assert_equal(
    #     "SEARCH user_idx \"`hello` -(`world`|`werld`)\"", query.to_redis
    #   )
    # end
    #
    # test "union inside phrase" do
    #   query = User.search("obama").or "barack", "barrack"
    #
    #   assert_equal(
    #     "SEARCH user_idx \"`hello` -(`world`|`werld`)\"", query.to_redis
    #   )
    # end
  end
end
