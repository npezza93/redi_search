# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class WithPayloads < ApplicationClause
        clause_order 5

        def clause
          validate!

          ["WITHPAYLOADS"]
        end
      end
    end
  end
end
