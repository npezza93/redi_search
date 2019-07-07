# frozen_string_literal: true

require "redi_search/lazily_load"

require "redi_search/search/clauses"
require "redi_search/search/term"
require "redi_search/search/result"

module RediSearch
  class Search
    include Enumerable
    include LazilyLoad
    include Clauses

    def initialize(index, term = nil, **term_options)
      @index = index
      @clauses = []
      @used_clauses = Set.new

      @term_clause = term.presence &&
        And.new(self, term, nil, **term_options)
    end

    def results
      if index.model.present?
        index.model.where(id: to_a.map(&:document_id_without_index))
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
        inspect_command_arg(arg)
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

    def inspect_command_arg(arg)
      if !arg.to_s.starts_with?(/\(-?@/) && arg.to_s.split(/\s|\|/).size > 1
        arg.inspect
      else
        arg
      end
    end

    def valid?
      term_clause.present?
    end
  end
end
