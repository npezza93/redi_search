# frozen_string_literal: true

module RediSearch
  class Schema
    class TextField < Field
      def initialize(
        name, 
        weight:   1.0, 
        phonetic: nil, 
        sortable: false,
        no_index: false, 
        no_stem:  false, 
        &block
      )
        @name = name
        @value_block = block

        { weight: weight, 
          phonetic: phonetic, 
          sortable: sortable,
          no_index: no_index, 
          no_stem: no_stem 
        }.each do |attr, value|
          instance_variable_set("@#{attr}", value)
        end
      end

      def to_a
        query = [name.to_s, "TEXT"]
        query += ["WEIGHT", weight] if weight
        query += ["PHONETIC", phonetic] if phonetic
        query += boolean_options_string

        query
      end

      private

      attr_reader :weight, 
                  :phonetic, 
                  :sortable, 
                  :no_index, 
                  :no_stem

      def boolean_options
        %i(sortable no_index no_stem)
      end
    end
  end
end
