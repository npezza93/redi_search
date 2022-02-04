# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class WhereTest < Minitest::Test
        def setup
          index = Index.new(:users) do
            text_field :first
          end
          @search = Search.new(index, "foo")
        end

        def test_to_s
          @clause = Where.new(@search, first: :bar)

          assert_equal "(@first:`bar`)", @clause.to_s
        end

        def test_prior_clause
          @clause = Where.new(
            @search, { first: :bar }, And.new(@search, "baz")
          )
          assert_equal "`baz` (@first:`bar`)", @clause.to_s
        end

        def test_notting
          @clause = Where.new(@search, nil)
          @clause.not(first: :baz)
          assert_equal "(-@first:`baz`)", @clause.to_s
        end
      end
    end
  end
end
