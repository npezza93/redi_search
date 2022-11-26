# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Reducers
      class Count < ApplicationClause
        clause_term :as

        def initialize(as:)
          @as = as
        end

        def clause
          validate!

          command =  ["REDUCE", "COUNT", 0]
          command += ["AS", as] if as
          command
        end
      end
    end
  end
end
