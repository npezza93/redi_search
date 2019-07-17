# frozen_string_literal: true

require "redi_search/validatable"

module RediSearch
  class Search
    module Clauses
      class ApplicationClause
        include Validatable

        def self.clause_term(term, **validations)
          attr_reader term
          validations.each do |validation_type, options|
            if options.is_a? Hash
              public_send("validates_#{validation_type}_of", term, **options)
            else
              public_send("validates_#{validation_type}_of", term)
            end
          end
        end
      end
    end
  end
end
