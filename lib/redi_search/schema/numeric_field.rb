# frozen_string_literal: true

module RediSearch
  class Schema
    class NumericField < Field
      def initialize(name, sortable: false, no_index: false, &block)
        @name        = name
        @sortable    = sortable
        @no_index    = no_index
        @value_block = block
      end

      def to_a
        query = [name.to_s, "NUMERIC"]
        query += boolean_options_string

        query
      end

      def cast(value)
        if value.to_s.include?(".")
          value.to_f
        else
          value.to_i
        end
      end

      private

      attr_reader :sortable, :no_index

      def boolean_options
        %i(sortable no_index)
      end
    end
  end
end
