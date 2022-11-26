# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Reducers
      class Sum < ApplicationClause
        clause_term :property, presence: true
        clause_term :as

        def initialize(property:, as:)
          @property = property.to_s
          @property.prepend("@") unless @property.start_with?("@")
          @as = as
        end

        def clause
          validate!

          command =  ["REDUCE", "SUM", 1, property]
          command += ["AS", as] if as
          command
        end
      end
    end
  end
end
