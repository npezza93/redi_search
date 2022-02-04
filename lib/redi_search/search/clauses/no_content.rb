# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class NoContent < ApplicationClause
        def clause
          validate!

          ["NOCONTENT"]
        end
      end
    end
  end
end
