# frozen_string_literal: true

module RediSearch
  class Search
    extend Forwardable
    include LazilyLoad
    include Clauses
    include Queries

    attr_reader :query, :used_clauses, :index, :clauses

    def_delegator :index, :model

    def initialize(index, term = nil, **term_options)
      @index = index
      @clauses = []
      @used_clauses = Set.new

      @query = term && And.new(self, term, nil, **term_options)
    end

    def results
      if model
        no_content unless loaded?

        model.where(id: to_a.map(&:document_id_without_index))
      else
        to_a
      end
    end

    def explain
      RediSearch.client.call!(
        "EXPLAINCLI", index.name, query.to_s
      ).join(" ").strip
    end

    def dup
      self.class.new(index)
    end

    private

    attr_writer :index, :clauses

    def command
      ["SEARCH", index.name, query.to_s,
       *clauses.sort_by(&:clause_order).flat_map(&:clause)]
    end

    def parse_response(response)
      @documents = Result.new(self, response[0], response[1..])
    end

    def valid?
      !query.to_s.empty?
    end
  end
end
