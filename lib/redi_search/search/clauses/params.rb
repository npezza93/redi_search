# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Params < ApplicationClause
        clause_term :fields, presence: true
        clause_order 23

        def initialize(fields:)
          @fields = fields
        end

        def clause
          validate!

          ["PARAMS", fields.size, *fields]
        end
      end
    end
  end
end
