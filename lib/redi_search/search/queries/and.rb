# frozen_string_literal: true

module RediSearch
  class Search
    module Queries
      class And < Boolean
        private

        def operand
          " "
        end
      end
    end
  end
end
