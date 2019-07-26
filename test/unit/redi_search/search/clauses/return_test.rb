# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class ReturnTest < Minitest::Test
        def setup
          @clause = Return
        end

        def test_clause
          assert_equal(
            ["RETURN", 2, :foo, :bar], @clause.new(fields: %i(foo bar)).clause
          )
        end

        def test_invalid_slop
          assert_raises ValidationError do
            @clause.new(fields: nil).clause
          end
        end
      end
    end
  end
end
