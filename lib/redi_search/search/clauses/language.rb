# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Language < ApplicationClause
        clause_term :language, presence: true

        def initialize(language:)
          @language = language
        end

        def clause
          validate!

          ["LANGUAGE", language]
        end
      end
    end
  end
end
