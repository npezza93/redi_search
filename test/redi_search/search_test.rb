# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/result"

module RediSearch
  class SearchTest < Minitest::Test
    def setup
      @index = Index.new("users_test", name: :text)
      @index.drop
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_query_execution
      query = RediSearch::Search.new(@index, "dr")
      assert_equal RediSearch::Search::Result, query.results.class
    end

    def test_highlight_command
      query = RediSearch::Search.new(@index, "dr")

      assert_equal(
        "SEARCH users_test `dr` HIGHLIGHT TAGS <b> </b>",
        query.highlight.to_redis
      )
    end

    def test_highlight_command_with_tags
      query = RediSearch::Search.new(@index, "dr")

      assert_equal(
        "SEARCH users_test `dr` HIGHLIGHT TAGS b bb",
        query.highlight(opening_tag: "b", closing_tag: "bb").to_redis
      )
    end

    def test_explain_query
      query = RediSearch::Search.new(@index, "dr")

      assert_equal("UNION { dr +dr(expanded) }", query.explain)
    end

    def test_terms_with_options
      query = User.search(:hello, fuzziness: 1)

      assert_equal("SEARCH users_test `%hello%`", query.to_redis)
    end

    def test_simple_phrase
      query = User.search("hello").and("world")

      assert_equal("SEARCH users_test \"`hello` `world`\"", query.to_redis)
    end

    def test_exact_phrase
      query = User.search("hello world")

      assert_equal(
        "SEARCH users_test \"`hello world`\"", query.to_redis
      )
    end

    def test_or_phrase
      query = User.search("hello").or "world"

      assert_equal(
        "SEARCH users_test \"`hello`|`world`\"", query.to_redis
      )
    end

    def test_and_phrase
      query = User.search("hello").and "world"

      assert_equal(
        "SEARCH users_test \"`hello` `world`\"", query.to_redis
      )
    end

    def test_and_not_phrase
      query = User.search("hello").and.not("world")

      assert_equal(
        "SEARCH users_test \"`hello` -`world`\"", query.to_redis
      )
    end

    def test_and_raises_arg_error_without_terms
      assert_raise ArgumentError do
        User.search("hello").and.to_s
      end
    end

    def test_and_not_raises_arg_error_without_terms
      assert_raise ArgumentError do
        User.search("hello").and.not.results
      end
    end

    def test_negation_of_or
      query = User.search("hello").or.not "world"

      assert_equal(
        "SEARCH users_test \"`hello`|-`world`\"", query.to_redis
      )
    end

    def test_searching_without_terms_returns_the_search_instance
      assert User.search.inspect.start_with? "#<RediSearch::Search:"
      assert User.search.inspect.is_a? String
      assert User.search("hellow").inspect.is_a? RediSearch::Search::Result
    end
  end
end
