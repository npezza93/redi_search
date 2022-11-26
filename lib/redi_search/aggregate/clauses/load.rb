# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class Load < ApplicationClause
        clause_term :fields, presence: true
        clause_order 2

        def initialize(fields:)
          @fields = fields
        end

        def clause
          validate!

          ["LOAD", fields.size, *fields]
        end
      end
    end
  end
end
