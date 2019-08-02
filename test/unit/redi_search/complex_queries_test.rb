# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ComplexQueriesTest < Minitest::Test
    def setup
      @index = Index.new(
        :users, name: :text, title: :text, description: :text, category: :text
      )
    end

    def test_and_not_multiple_phrase
      assert_query("`hello` -(`world`|`werld`)") do
        @index.search("hello").and.not(@index.search("world").or("werld"))
      end
    end

    def test_intersection_of_unions
      assert_query("`hello`|`halo` (`world`|`werld`)") do
        @index.search("hello").or("halo").
          and(@index.search("world").or("werld"))
      end
    end

    def test_union_inside_phrase
      assert_query("`foo` (`bar`|`baz`)") do
        @index.search("foo").and(@index.search("bar").or("baz"))
      end
    end

    def test_multiple_optional_terms_with_higher_priority
      assert_query("`foo` `~bar` `~baz`") do
        @index.search("foo").and("bar", optional: true).
          and("baz", optional: true)
      end
    end

    def test_exact_phrase_in_one_field_one_word_in_another_field
      assert_query("(@name:`foo bar`) (@title:`vip`)") do
        @index.search.where(name: "foo bar").where(title: "vip")
      end
    end

    # rubocop:disable Metrics/MethodLength
    def test_combined_and_or_with_field_specifiers
      expected = "`world` (@title:`hello`) (@description:(`foo` `bar`)) "\
        "(@category:(`articles`|`biographies`))"

      assert_query(expected) do
        @index.search("world").where(title: "hello").
          where(description: @index.search("foo").and("bar")).
          where(category: @index.search("articles").or("biographies"))
      end
    end
    # rubocop:enable Metrics/MethodLength

    def test_simple_phrase
      assert_query("`hello` `world`") do
        @index.search("hello").and("world")
      end
    end

    def test_exact_phrase
      assert_query("`hello world`") do
        @index.search("hello world")
      end
    end

    def test_or_phrase
      assert_query("`hello`|`world`") do
        @index.search("hello").or "world"
      end
    end

    def test_and_phrase
      assert_query("`hello` `world`") do
        @index.search("hello").and "world"
      end
    end

    def test_and_not_phrase
      assert_query("`hello` -`world`") do
        @index.search("hello").and.not("world")
      end
    end

    def test_negation_of_or
      assert_query("`hello`|-`world`") do
        @index.search("hello").or.not "world"
      end
    end

    private

    def assert_query(expected)
      client = Minitest::Mock.new.expect(:call!, Client::Response.new([0]),
                                         ["SEARCH", @index.name, expected])
      RediSearch.stub :client, client do
        yield.load
      end

      assert_mock client
    end
  end
end
