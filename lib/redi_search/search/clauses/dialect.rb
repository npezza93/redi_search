# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Dialect < ApplicationClause
        clause_term :dialect, numericality: { within: 0..Float::INFINITY }
        clause_order 21

        def initialize(dialect:)
          @dialect = dialect
        end

        def clause
          validate!

          ["DIALECT", dialect]
        end
      end
    end
  end
end
