# frozen_string_literal: true

require "redi_search/lazy_loadable"
require "redi_search/spellcheck/result"

module RediSearch
  class Spellcheck
    include LazyLoadable
    include Enumerable

    def initialize(index, terms, distance: 1)
      @index = index
      @terms = terms
      @distance = distance
    end

    delegate :count, :each, to: :to_a

    private

    attr_reader :documents
    attr_accessor :index, :terms, :distance

    def command
      ["SPELLCHECK", index.name, terms, "DISTANCE", distance]
    end

    def parsed_terms
      terms.split(Regexp.union(",.<>{}[]\"':;!@#$%^&*()-+=~\s".split("")))
    end

    def parse_response(response)
      @documents = response.map do |suggestion|
        Result.new(*suggestion[1..2])
      end
    end
  end
end
