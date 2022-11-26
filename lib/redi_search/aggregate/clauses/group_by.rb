# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class GroupBy < ApplicationClause
        clause_term :fields, presence: true
        clause_order 3

        def initialize(fields:)
          @fields = fields.map(&:to_s).map do |field|
            field.prepend("@") unless field.start_with?("@")
          end
          @reducer = nil
        end

        def clause
          validate!

          ["GROUPBY", fields.count, *fields, *reducer&.clause].compact
        end

        def count(as: nil)
          self.reducer = Reducers::Count.new(as: as).tap(&:validate!)
        end

        def distinct_count(property:, as: nil)
          self.reducer = Reducers::DistinctCount.
                         new(property: property, as: as).tap(&:validate!)
        end

        def distinctish_count(property:, as: nil)
          self.reducer = Reducers::DistinctishCount.
                         new(property: property, as: as).tap(&:validate!)
        end

        def sum(property:, as: nil)
          self.reducer = Reducers::Sum.
                         new(property: property, as: as).tap(&:validate!)
        end

        def min(property:, as: nil)
          self.reducer = Reducers::Min.
                         new(property: property, as: as).tap(&:validate!)
        end

        def max(property:, as: nil)
          self.reducer = Reducers::Max.
                         new(property: property, as: as).tap(&:validate!)
        end

        def average(property:, as: nil)
          self.reducer = Reducers::Average.
                         new(property: property, as: as).tap(&:validate!)
        end

        def stdev(property:, as: nil)
          self.reducer = Reducers::Stdev.
                         new(property: property, as: as).tap(&:validate!)
        end

        def quantile(property:, quantile:, as: nil)
          self.reducer = Reducers::Quantile.new(
            property: property, quantile: quantile, as: as
          ).tap(&:validate!)
        end

        def to_list(property:, as: nil)
          self.reducer = Reducers::ToList.
                         new(property: property, as: as).tap(&:validate!)
        end

        private

        attr_accessor :reducer
      end
    end
  end
end
