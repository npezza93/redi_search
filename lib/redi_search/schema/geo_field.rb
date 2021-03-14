# frozen_string_literal: true

require "redi_search/schema/field"

module RediSearch
  class Schema
    class GeoField < Field
      def initialize(name, sortable: false, no_index: false)
        @name = name
        @sortable = sortable
        @no_index = no_index
      end

      def to_a
        query = [name.to_s, "GEO"]
        query += boolean_options_string

        query
      end

      private

      attr_reader :sortable, :no_index

      def boolean_options
        %i(sortable no_index)
      end
    end
  end
end
