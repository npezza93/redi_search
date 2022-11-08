# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class OrTest < Minitest::Test
        include BooleanInterfaceTest

        def setup
          index = Index.new(:users) do
            text_field :first
          end
          @search = Search.new(index, "foo")
          @clause = Or.new(@search, "bar")
        end

        def test_to_s
          assert_equal "`bar`", @clause.to_s
        end

        def test_prior_clause
          @clause = Or.new(@search, "bar", Or.new(@search, "baz"))

          assert_equal "`baz`|`bar`", @clause.to_s
        end

        def test_term_is_search
          @clause = Or.new(@search, @search, Or.new(@search, "baz"))

          assert_equal "`baz`|(`foo`)", @clause.to_s
        end

        def test_term_is_nil
          @clause = Or.new(@search, nil)

          assert_raises ArgumentError do
            @clause.to_s
          end
        end

        def test_notting
          @clause = Or.new(@search, nil)
          @clause.not("baz")

          assert_equal "-`baz`", @clause.to_s
        end

        def test_where
          @clause = Or.new(@search, nil, @search.term_clause)
          @clause.where(first: "baz")

          assert_equal "`foo`|(@first:`baz`)", @clause.to_s
        end
      end
    end
  end
end
