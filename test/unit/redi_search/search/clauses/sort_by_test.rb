# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class SortByTest < Minitest::Test
        def setup
          @clause = SortBy
        end

        def test_clause
          assert_equal(
            ["SORTBY", :field, :asc],
            @clause.new(field: :field).clause
          )
        end

        def test_clause_with_desc_order
          assert_equal(
            ["SORTBY", :field, :desc],
            @clause.new(field: :field, order: :desc).clause
          )
        end

        def test_order_validation
          assert_raises ValidationError do
            @clause.new(field: :field, order: :random).clause
          end
        end

        def test_field_validation
          assert_raises ValidationError do
            @clause.new(field: nil).clause
          end
        end
      end
    end
  end
end
