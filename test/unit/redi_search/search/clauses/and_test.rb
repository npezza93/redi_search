# frozen_string_literal: true

require "test_helper"
require "unit/redi_search/search/clauses/boolean_interface_test"

module RediSearch
  class Search
    module Clauses
      class AndTest < Minitest::Test
        include BooleanInterfaceTest

        def setup
          index = Index.new(:users) do
            text_field :first
          end
          @search = Search.new(index, "foo")
          @clause = And.new(@search, "bar")
        end

        def test_to_s
          assert_equal "`bar`", @clause.to_s
        end

        def test_prior_clause
          @clause = And.new(@search, "bar", And.new(@search, "baz"))
          assert_equal "`baz` `bar`", @clause.to_s
        end

        def test_term_is_search
          @clause = And.new(@search, @search, And.new(@search, "baz"))
          assert_equal "`baz` (`foo`)", @clause.to_s
        end

        def test_term_is_nil
          @clause = And.new(@search, nil)

          assert_raises ArgumentError do
            @clause.to_s
          end
        end

        def test_notting
          @clause = And.new(@search, nil)
          @clause.not("baz")
          assert_equal "-`baz`", @clause.to_s
        end
      end
    end
  end
end
