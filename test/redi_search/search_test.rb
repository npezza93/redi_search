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

    test "and not multiple phrase" do
      query = User.search("hello").and.not(
        User.search("world").or("werld")
      )

      assert_equal(
        "SEARCH users_test \"`hello` -(`world`|`werld`)\"", query.to_redis
      )
    end

    test "intersection of unions" do
      query = User.search("hello").or("halo").and(
        User.search("world").or("werld")
      )

      assert_equal(
        "SEARCH users_test \"`hello`|`halo` (`world`|`werld`)\"", query.to_redis
      )
    end

    test "union inside phrase" do
      query = User.search("obama").and(User.search("barack").or("barrack"))

      assert_equal(
        "SEARCH users_test \"`obama` (`barack`|`barrack`)\"", query.to_redis
      )
    end

    test "multiple optional terms with higher priority" do
      query = User.search("obama").and("barack", optional: true).and(
        "michelle", optional: true
      )

      assert_equal(
        "SEARCH users_test \"`obama` `~barack` `~michelle`\"", query.to_redis
      )
    end

    test "exact phrase in one field, one word in another field" do
      query =
        User.search.where(title: "barack obama").where(job: "president")

      assert_equal(
        "SEARCH users_test (@title:`barack obama`) (@job:`president`)",
        query.to_redis
      )
    end

    test "combined AND, OR with field specifiers" do
      query = User.search("world").where(title: "hello").where(
        body: User.search("foo").and("bar")
      ).where(category: User.search("articles").or("biographies"))

      expected = <<~CLAUSE.squish
        `world` (@title:`hello`) (@body:(`foo` `bar`))
        (@category:(`articles`|`biographies`))
      CLAUSE

      assert_equal("SEARCH users_test \"#{expected}\"", query.to_redis)
    end
  end
end
