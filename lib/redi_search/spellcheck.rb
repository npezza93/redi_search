# frozen_string_literal: true

module RediSearch
  class Spellcheck
    include Enumerable

    def initialize(index, query, distance: 1)
      @index = index
      @query = query
      @distance = distance
      @loaded = false
    end

    #:nocov:
    def pretty_print(printer)
      execute unless loaded?

      printer.pp(documents)
    rescue Redis::CommandError => e
      printer.pp(e.message)
    end
    #:nocov:

    def loaded?
      @loaded
    end

    def to_a
      execute unless loaded?

      @documents
    end

    delegate :count, :each, to: :to_a

    private

    attr_reader :documents
    attr_accessor :index, :query, :distance

    def command
      ["SPELLCHECK", index.name, query, "DISTANCE", distance]
    end

    def execute
      @loaded = true

      RediSearch.client.call!(*command).yield_self do |results|
        @documents = results
      end
    end
  end
end
