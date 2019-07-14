# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/result"

module RediSearch
  class SearchTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("users_test", name: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "query execution" do
      query = RediSearch::Search.new(@index, "dr")
      assert_equal RediSearch::Search::Result, query.results.class
    end

    test "highlight command" do
      query = RediSearch::Search.new(@index, "dr")

      assert_equal(
        "SEARCH users_test `dr` HIGHLIGHT TAGS <b> </b>",
        query.highlight.to_redis
      )
    end

    test "highlight command with tags" do
      query = RediSearch::Search.new(@index, "dr")

      assert_equal(
        "SEARCH users_test `dr` HIGHLIGHT TAGS b bb",
        query.highlight(opening_tag: "b", closing_tag: "bb").to_redis
      )
    end

    test "explain query" do
      query = RediSearch::Search.new(@index, "dr")

      assert_equal("UNION { dr +dr(expanded) }", query.explain)
    end

    test "terms with options" do
      query = User.search(:hello, fuzziness: 1)

      assert_equal("SEARCH users_test `%hello%`", query.to_redis)
    end

    test "simple phrase" do
      query = User.search("hello").and("world")

      assert_equal("SEARCH users_test \"`hello` `world`\"", query.to_redis)
    end

    test "exact phrase" do
      query = User.search("hello world")

      assert_equal(
        "SEARCH users_test \"`hello world`\"", query.to_redis
      )
    end

    test "or phrase" do
      query = User.search("hello").or "world"

      assert_equal(
        "SEARCH users_test \"`hello`|`world`\"", query.to_redis
      )
    end

    test "and phrase" do
      query = User.search("hello").and "world"

      assert_equal(
        "SEARCH users_test \"`hello` `world`\"", query.to_redis
      )
    end

    test "and not phrase" do
      query = User.search("hello").and.not("world")

      assert_equal(
        "SEARCH users_test \"`hello` -`world`\"", query.to_redis
      )
    end

    test "and raises arg error without terms" do
      assert_raise ArgumentError do
        User.search("hello").and.to_s
      end
    end

    test "and not raises arg error without terms" do
      assert_raise ArgumentError do
        User.search("hello").and.not.results
      end
    end

    test "negation of or" do
      query = User.search("hello").or.not "world"

      assert_equal(
        "SEARCH users_test \"`hello`|-`world`\"", query.to_redis
      )
    end

    test "searching without terms returns the search instance" do
      assert User.search.inspect.start_with? "#<RediSearch::Search:"
      assert User.search.inspect.is_a? String
      assert User.search("hellow").inspect.is_a? RediSearch::Search::Result
    end
  end
end
