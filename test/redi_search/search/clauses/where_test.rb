# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class WhereTest < Minitest::Test
        def setup
          @index = Index.new(:users_test, name: :text)
          @index.drop
          @index.create
        end

        def teardown
          @index.drop
        end

        def test_where_clause_is_field_specific
          query = @index.search.where(name: :foo)

          assert_equal(
            "SEARCH users_test (@name:`foo`)",
            query.to_redis
          )
        end

        def test_where_clause_can_take_query
          query = @index.search.where(name: @index.search("foo").or("bar"))

          assert_equal(
            "SEARCH users_test (@name:(`foo`|`bar`))",
            query.to_redis
          )
        end

        def test_negate_where_clause
          query = @index.search.where(x: :foo).where.not(y: :bar)

          assert_equal(
            "SEARCH users_test (@x:`foo`) (-@y:`bar`)",
            query.to_redis
          )
        end

        def test_negate_where_union_clause
          query = @index.search.where.not(x: @index.search("foo").or("bar"))

          assert_equal(
            "SEARCH users_test (-@x:(`foo`|`bar`))",
            query.to_redis
          )
        end

        def test_where_with_prefix
          query = @index.search.where(name: :john, prefix: true)

          assert_equal(
            "SEARCH users_test (@name:`john*`)",
            query.to_redis
          )
        end

        def test_or_two_where_clauses
          query = @index.search.where(x: :foo).or.where(y: :bar)

          assert_equal(
            "SEARCH users_test (@x:`foo`)|(@y:`bar`)",
            query.to_redis
          )
        end

        def test_between_range
          query = @index.search.where(num: 10..20)

          assert_equal(
            "SEARCH users_test (@num:[10 20])",
            query.to_redis
          )
        end

        def test_greater_than_num
          query = @index.search.where(num: 10..Float::INFINITY)

          assert_equal(
            "SEARCH users_test (@num:[10 +inf])",
            query.to_redis
          )
        end

        def test_less_than_num
          query = @index.search.where(num: -Float::INFINITY..10)

          assert_equal(
            "SEARCH users_test (@num:[-inf 10])",
            query.to_redis
          )
        end

        def test_complex_ranges
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
end
