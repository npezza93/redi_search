# frozen_string_literal: true

module RediSearch
  class Spellcheck
    include LazilyLoad
    include Validatable

    validates_numericality_of :distance, within: 1..4, only_integer: true

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
      terms.split(Regexp.union(",.<>{}[]\"':;!@#$%^&*()-+=~\s".chars))
    end

    def execute
      validate!

      @loaded = true

      RediSearch.client.call!(*command).then do |response|
        parse_response(response)
      end
    end

    def parse_response(response)
      suggestions = response.to_h do |suggestion|
        suggestion[1..2]
      end

      @documents = parsed_terms.map do |term|
        Result.new(term, suggestions[term] || [])
      end
    end
  end
end
