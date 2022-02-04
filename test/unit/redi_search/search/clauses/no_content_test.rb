# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class NoContentTest < Minitest::Test
        def setup
          @clause = NoContent
        end

        def test_clause
          assert_equal ["NOCONTENT"], @clause.new.clause
        end
      end
    end
  end
end
