# frozen_string_literal: true

require "redi_search/validatable"

module RediSearch
  class Search
    module Clauses
      class ApplicationClause
        include Validatable

        class << self
          def clause_term(term, **validations)
            attr_reader term

            validations.each do |validation_type, options|
              define_validation(term, validation_type, options)
            end
          end

          private

          def define_validation(term, type, options)
            if options.is_a? Hash
              public_send("validates_#{type}_of", term, **options)
            else
              public_send("validates_#{type}_of", term)
            end
          end
        end
      end
    end
  end
end
