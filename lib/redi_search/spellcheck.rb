# frozen_string_literal: true

require "redi_search/lazily_load"
require "redi_search/spellcheck/result"

module RediSearch
  class Spellcheck
    include LazilyLoad
    include ActiveModel::Validations

    validates :distance, numericality: {
      greater_than: 0, less_than: 5
    }

    def initialize(index, terms, distance: 1)
      @index = index
      @terms = terms
      @distance = distance
    end

    private

    attr_reader :documents
    attr_accessor :index, :terms, :distance

    def command
      ["SPELLCHECK", index.name, terms, "DISTANCE", distance]
    end

    def parsed_terms
      terms.split(Regexp.union(",.<>{}[]\"':;!@#$%^&*()-+=~\s".split("")))
    end

    def execute
      validate!

      @loaded = true

      RediSearch.client.call!(*command).yield_self do |response|
        parse_response(response)
      end
    end

    def parse_response(response)
      suggestions = response.map do |suggestion|
        suggestion[1..2]
      end.to_h

      @documents = parsed_terms.map do |term|
        Result.new(term, suggestions[term] || [])
      end
    end
  end
end
