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
    end
  end
end
