# frozen_string_literal: true

require "test_helper"
require "redi_search/search"
require "redi_search/search/result"

module RediSearch
  class ComplexQueriesTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("users_test", name: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
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
