# frozen_string_literal: true

require "redi_search/search/clauses"
require "redi_search/search/term"
require "redi_search/search/highlight_clause"
require "redi_search/result/collection"

module RediSearch
  class Search
    include Enumerable
    include Clauses

    def initialize(index, model = nil, *terms, **terms_with_options)
      @index = index
      @model = model
      @term_clause = AndClause.new(self, nil, *terms, **terms_with_options)
      @loaded = false
      @clauses = []
    end

    def pretty_print(printer)
      execute unless loaded?

      printer.pp(records)
    rescue Redis::CommandError => e
      printer.pp(e.message)
    end

    def loaded?
      @loaded
    end

    def to_a
      execute unless loaded?

      @records
    end

    def results
      model.where(id: to_a.map(&:document_id))
    end

    delegate :count, :each, to: :to_a

    def to_redis
      command.map do |arg|
        if arg.to_s.split(/\s|\|/).size > 1
          arg.inspect
        else
          arg
        end
      end.join(" ")
    end

    attr_reader :term_clause

    private

    attr_reader :records
    attr_accessor :index, :model, :clauses

    def command
      ["SEARCH", index.name, term_clause, *clauses]
    end

    def execute
      @loaded = true

      RediSearch.client.call!(*command).then do |results|
        @records = Result::Collection.new(index, results[0], results[1..-1])
      end
    end
  end
end
