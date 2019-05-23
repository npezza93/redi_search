# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class WhereClauseTest < ActiveSupport::TestCase
      setup do
        @index = Index.new("users_test", name: :text)
        @index.drop
        @index.create
      end

      teardown do
        @index.drop
      end

      test "where clause is field specific" do
        query = @index.search.where(name: :foo)

        assert_equal(
          "SEARCH users_test (@name:`foo`)",
          query.to_redis
        )
      end

      test "where clause can take query" do
        query = @index.search.where(name: @index.search("foo").or("bar"))

        assert_equal(
          "SEARCH users_test (@name:(`foo`|`bar`))",
          query.to_redis
        )
      end

      test "negate where clause" do
        query = @index.search.where(x: :foo).where.not(y: :bar)

        assert_equal(
          "SEARCH users_test (@x:`foo`) (-@y:`bar`)",
          query.to_redis
        )
      end

      test "negate where union clause" do
        query = @index.search.where.not(x: @index.search("foo").or("bar"))

        assert_equal(
          "SEARCH users_test (-@x:(`foo`|`bar`))",
          query.to_redis
        )
      end

      test "where with prefix" do
        query = @index.search.where(name: :john, prefix: true)

        assert_equal(
          "SEARCH users_test (@name:`john*`)",
          query.to_redis
        )
      end

      test "or two where clauses" do
        query = @index.search.where(x: :foo).or.where(y: :bar)

        assert_equal(
          "SEARCH users_test (@x:`foo`)|(@y:`bar`)",
          query.to_redis
        )
      end

      test "between range" do
        query = @index.search.where(num: 10..20)

        assert_equal(
          "SEARCH users_test (@num:[10 20])",
          query.to_redis
        )
      end

      test "greater than num" do
        query = @index.search.where(num: 10..Float::INFINITY)

        assert_equal(
          "SEARCH users_test (@num:[10 +inf])",
          query.to_redis
        )
      end

      test "less than num" do
        query = @index.search.where(num: -Float::INFINITY..10)

        assert_equal(
          "SEARCH users_test (@num:[-inf 10])",
          query.to_redis
        )
      end

      test "complex ranges" do
        query = @index.search.
                where(num: -Float::INFINITY..9).
                or.where(num: 21..Float::INFINITY)

        assert_equal(
          "SEARCH users_test (@num:[-inf 9])|(@num:[21 +inf])",
          query.to_redis
        )
      end
    end
  end
end
