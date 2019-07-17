# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class Slop < ApplicationClause
        clause_term :slop, numericality: { within: 0..Float::INFINITY }

        def initialize(slop:)
          @slop = slop
        end

        def clause
          validate!

          ["SLOP", slop]
        end
      end
    end
  end
end
