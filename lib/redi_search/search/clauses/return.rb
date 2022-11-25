# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Return < ApplicationClause
        clause_term :fields, presence: true
        clause_order 10

        def initialize(fields:)
          @fields = fields
        end

        def clause
          validate!

          ["RETURN", fields.size, *fields]
        end
      end
    end
  end
end
