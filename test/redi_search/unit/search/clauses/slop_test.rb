# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class SlopTest < Minitest::Test
        def setup
          @clause = Slop
        end

        def test_clause
          assert_equal ["SLOP", 1], @clause.new(slop: 1).clause
        end

        def test_invalid_slop
          assert_raises ValidationError do
            @clause.new(slop: -1).clause
          end
        end
      end
    end
  end
end
