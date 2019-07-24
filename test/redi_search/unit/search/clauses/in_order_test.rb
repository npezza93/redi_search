# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class InOrderTest < Minitest::Test
        def setup
          @clause = InOrder
        end

        def test_clause
          assert_equal ["INORDER"], @clause.new.clause
        end
      end
    end
  end
end
