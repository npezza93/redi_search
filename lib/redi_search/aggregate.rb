# frozen_string_literal: true

module RediSearch
  class Aggregate
    class MissingGroupByClause < StandardError
    end

    extend Forwardable
    include LazilyLoad
    include Search::Queries

    attr_reader :query, :used_clauses, :index, :clauses

    def_delegator :index, :model

    def initialize(index, term = nil, **term_options)
      @index = index
      @clauses = []
      @used_clauses = Set.new

      @query = term && Search::Queries::And.new(self, term, nil, **term_options)
    end

    def verbatim
      add_to_clauses(Clauses::Verbatim.new)
    end

    def load(*fields)
      add_to_clauses(Clauses::Load.new(fields:))
    end

    def group_by(*fields)
      add_to_clauses(Clauses::GroupBy.new(fields:))
    end

    def count(as: nil)
      clause = clauses.reverse.find { |cl| cl.is_a?(Clauses::GroupBy) } ||
        raise(MissingGroupByClause, "call group_by first")

      clause.count(as:)
      self
    end

    def quantile(property: nil, quantile: nil, as: nil)
      clause = clauses.reverse.find { |cl| cl.is_a?(Clauses::GroupBy) } ||
        raise(MissingGroupByClause, "call group_by first")

      clause.count(property:, quantile:, as:)

      self
    end

    %i(distinct_count distinctish_count sum min max average stdev to_list).
      each do |reducer|
      define_method(reducer) do |property, as: nil|
        clause = clauses.reverse.find { |cl| cl.is_a?(Clauses::GroupBy) } ||
          raise(MissingGroupByClause, "call group_by first")

        clause.public_send(reducer, property:, as:)
        self
      end
    end

    def sort_by(*fields)
      add_to_clauses(Clauses::SortBy.new(fields:))
    end

    def apply(expression, as:)
      add_to_clauses(Clauses::Apply.new(expression:, as:))
    end

    def filter(expression)
      add_to_clauses(Clauses::Filter.new(expression:))
    end

    def limit(total, offset = 0)
      add_to_clauses(Clauses::Limit.new(total:, offset:))
    end

    private

    attr_writer :index, :clauses

    def command
      ["AGGREGATE", index.name, query.to_s,
       *clauses.sort_by(&:clause_order).flat_map(&:clause)]
    end

    def parse_response(response)
      @documents = response
    end

    def valid?
      !query.to_s.empty?
    end

    def add_to_clauses(clause)
      clause.validate! && clauses.push(clause) if
        used_clauses.add?(clause.class)

      self
    end
  end
end
