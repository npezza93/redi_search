# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class WhereClauseTest < ActiveSupport::TestCase
      setup do
        @index = Index.new("user_idx", name: :text)
        @index.drop
        @index.create
      end

      teardown do
        @index.drop
      end

      test "where clause is field specific" do
        query = @index.search.where(name: :foo)

        assert_equal(
          "SEARCH user_idx (@name:`foo`)",
          query.to_redis
        )
      end

      test "where clause can take query" do
        query = @index.search.where(name: @index.search("foo").or("bar"))

        assert_equal(
          "SEARCH user_idx (@name:(`foo`|`bar`))",
          query.to_redis
        )
      end

      test "negate where clause" do
        query = @index.search.where(x: :foo).where.not(y: :bar)

        assert_equal(
          "SEARCH user_idx (@x:`foo`) (-@y:`bar`)",
          query.to_redis
        )
      end

      test "negate where union clause" do
        query = @index.search.where.not(x: @index.search("foo").or("bar"))

        assert_equal(
          "SEARCH user_idx (-@x:(`foo`|`bar`))",
          query.to_redis
        )
      end

      test "where with prefix" do
        query = @index.search.where(name: :john, prefix: true)

        assert_equal(
          "SEARCH user_idx (@name:`john*`)",
          query.to_redis
        )
      end

      test "or two where clauses" do
        query = @index.search.where(x: :foo).or.where(y: :bar)

        assert_equal(
          "SEARCH user_idx (@x:`foo`)|(@y:`bar`)",
          query.to_redis
        )
      end
    end
  end
end
