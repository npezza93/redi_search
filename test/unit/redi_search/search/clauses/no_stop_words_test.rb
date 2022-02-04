# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class NoStopWordsTest < Minitest::Test
        def setup
          @clause = NoStopWords
        end

        def test_clause
          assert_equal ["NOSTOPWORDS"], @clause.new.clause
        end
      end
    end
  end
end
