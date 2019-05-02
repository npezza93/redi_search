# frozen_string_literal: true

require "redi_search/search/clauses"
require "redi_search/search/highlight_clause"

module RediSearch
  class Search
    include Enumerable
    include Clauses

    def initialize(index, term, model = nil, **options)
      @index = index
      @model = model
      @loaded = false
      @clauses = []
    end

    def pretty_print(printer)
      execute unless loaded?

      printer.pp(records)
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
      command.join(" ")
    end

    private

    attr_reader :records
    attr_accessor :index, :term_clause, :model, :clauses

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
