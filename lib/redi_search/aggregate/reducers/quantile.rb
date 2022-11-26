# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Reducers
      class Quantile < ApplicationClause
        clause_term :property, presence: true
        clause_term :quantile, presence: true, inclusion: {
          within: 0.0..1.0
        }
        clause_term :as

        def initialize(property:, quantile:, as:)
          @property = property.to_s
          @property.prepend("@") unless @property.start_with?("@")
          @quantile = quantile
          @as = as
        end

        def clause
          validate!

          command =  ["REDUCE", "QUANTILE", 2, property, quantile]
          command += ["AS", as] if as
          command
        end
      end
    end
  end
end
