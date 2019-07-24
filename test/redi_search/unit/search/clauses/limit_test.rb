# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class LimitTest < Minitest::Test
        def setup
          @clause = Limit
        end

        def test_clause
          assert_equal ["LIMIT", 0, 1], @clause.new(total: 1).clause
        end

        def test_clause_with_offset
          assert_equal(
            ["LIMIT", 5, 1], @clause.new(total: 1, offset: 5).clause
          )
        end

        def test_invalid_total
          assert_raises(ValidationError) { @clause.new(total: nil).clause }
          assert_raises(ValidationError) { @clause.new(total: -1).clause }
          assert_raises(ValidationError) { @clause.new(total: 10.5).clause }
        end

        def test_invalid_offset
          [nil, -1, 10.5].each do |offset|
            assert_raises(ValidationError) do
              @clause.new(total: 1, offset: offset).clause
            end
          end
        end
      end
    end
  end
end
