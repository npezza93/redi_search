# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class VerbatimTest < Minitest::Test
        def setup
          @clause = Verbatim
        end

        def test_clause
          assert_equal ["VERBATIM"], @clause.new.clause
        end
      end
    end
  end
end
