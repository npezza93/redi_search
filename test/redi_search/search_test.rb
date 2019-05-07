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
      query = RediSearch::Search.new(@index, nil, "dr")
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

    test "and phrase" do
      query = User.search("hello").and "world"

      assert_equal(
        "SEARCH user_idx \"`hello` `world`\"", query.to_redis
      )
    end

    test "and not phrase" do
      query = User.search("hello").and.not "world"

      assert_equal(
        "SEARCH user_idx \"`hello` -`world`\"", query.to_redis
      )
    end

    test "and raises arg error without terms" do
      assert_raise ArgumentError do
        User.search("hello").and.to_s
      end
    end

    test "and not raises arg error without terms" do
      assert_raise ArgumentError do
        User.search("hello").and.not.to_a
      end
    end

    test "negation of or" do
      query = User.search("hello").or.not "world"

      assert_equal(
        "SEARCH user_idx \"`hello`|-`world`\"", query.to_redis
      )
    end

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
