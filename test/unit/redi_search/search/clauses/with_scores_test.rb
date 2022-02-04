# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class WithScoresTest < Minitest::Test
        def setup
          @clause = WithScores
        end

        def test_clause
          assert_equal ["WITHSCORES"], @clause.new.clause
        end
      end
    end
  end
end
