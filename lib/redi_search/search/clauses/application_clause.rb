# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class ApplicationClause
        include ActiveModel::Validations

        def self.clause_term(term, *validations)
          attr_reader term
          validations.each do |validation|
            validates term, validation
          end
        end
      end
    end
  end
end
