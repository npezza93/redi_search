# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      module BooleanInterfaceTest
        def test_respond_to_to_s
          assert_respond_to @clause, :to_s
        end

        def test_respond_to_not
          assert_respond_to @clause, :not
        end

        def test_to_s
          refute_empty @clause.to_s
        end
      end
    end
  end
end
