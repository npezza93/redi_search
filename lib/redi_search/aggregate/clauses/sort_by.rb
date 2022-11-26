# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class SortBy < ApplicationClause
        class Sortable < ApplicationClause
          clause_term :field, presence: true
          clause_term :order, presence: true,
                              inclusion: { within: %i(asc desc) }

          def initialize(field, order = :asc)
            @field = field.to_s
            @field.prepend("@") unless @field.start_with?("@")
            @order = order.to_sym
          end

          def clause
            [field, order.to_s.upcase]
          end
        end

        clause_term :fields, presence: true
        clause_order 4

        def initialize(fields:)
          @fields = fields.flat_map do |field|
            if field.is_a?(Hash) then field.map { |k, v| Sortable.new(k, v) }
            else
              Sortable.new(field)
            end
          end
        end

        def clause
          validate! && fields.each(&:validate!)

          ["SORTBY", fields.count * 2, *fields.flat_map(&:clause)]
        end
      end
    end
  end
end
