# frozen_string_literal: true

require "redi_search/lazily_load"

require "redi_search/search/clauses"
require "redi_search/search/term"
require "redi_search/search/result"

module RediSearch
  class Search
    include Enumerable
    include Clauses
    include LazilyLoad

    def initialize(index, term = nil, **term_options)
      @index = index
      @clauses = []
      @used_clauses = Set.new

      @term_clause = term.presence &&
        AndClause.new(self, term, nil, **term_options)
    end

    def results
      if index.model.present?
        index.model.where(id: to_a.map(&:document_id))
      else
        to_a
      end
    end

    def explain
      RediSearch.client.call!(
        "EXPLAINCLI", index.name, term_clause
      ).join(" ").strip
    end

    def to_redis
      command.map do |arg|
        if !arg.to_s.starts_with?(/\(-?@/) && arg.to_s.split(/\s|\|/).size > 1
          arg.inspect
        else
          arg
        end
      end.join(" ")
    end

    def dup
      self.class.new(index)
    end

    attr_reader :term_clause

    private

    attr_reader :documents, :used_clauses
    attr_accessor :index, :clauses

    def command
      ["SEARCH", index.name, term_clause, *clauses.uniq]
    end

    def parse_response(response)
      @documents = Result.new(index, used_clauses, response[0], response[1..-1])
    end
  end
end
