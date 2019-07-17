# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/result"

module RediSearch
  class ComplexQueriesTest < Minitest::Test
    def setup
      @index = Index.new("users_test", name: :text)
      @index.drop
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_and_not_multiple_phrase
      query = User.search("hello").and.not(
        User.search("world").or("werld")
      )

      assert_equal(
        "SEARCH users_test \"`hello` -(`world`|`werld`)\"", query.to_redis
      )
    end

    def test_intersection_of_unions
      query = User.search("hello").or("halo").and(
        User.search("world").or("werld")
      )

      assert_equal(
        "SEARCH users_test \"`hello`|`halo` (`world`|`werld`)\"", query.to_redis
      )
    end

    def test_union_inside_phrase
      query = User.search("obama").and(User.search("barack").or("barrack"))

      assert_equal(
        "SEARCH users_test \"`obama` (`barack`|`barrack`)\"", query.to_redis
      )
    end

    def test_multiple_optional_terms_with_higher_priority
      query = User.search("obama").and("barack", optional: true).and(
        "michelle", optional: true
      )

      assert_equal(
        "SEARCH users_test \"`obama` `~barack` `~michelle`\"", query.to_redis
      )
    end

    def test_exact_phrase_in_one_field_one_word_in_another_field
      query =
        User.search.where(title: "barack obama").where(job: "president")

      assert_equal(
        "SEARCH users_test (@title:`barack obama`) (@job:`president`)",
        query.to_redis
      )
    end

    def test_combined_and_or_with_field_specifiers
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
