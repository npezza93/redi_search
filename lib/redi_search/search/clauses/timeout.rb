# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Timeout < ApplicationClause
        clause_term :timeout,
                    numericality: { within: 0..Float::INFINITY,
                                    only_integer: true }
        clause_order 14

        def initialize(timeout:)
          @timeout = timeout
        end

        def clause
          validate!

          ["TIMEOUT", timeout]
        end
      end
    end
  end
end
