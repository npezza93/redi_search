# frozen_string_literal: true

require "active_record/type"

module RailsRedisSearch
  class Schema
    class NumericField
      def initialize(name, sortable: false, no_index: false)
        @name = name
        @sortable = sortable
        @no_index = no_index
      end

      def to_s
        query = [name, "NUMERIC"]
        query += boolean_options_string

        query.join(" ")
      end

      private

      attr_reader :name, :sortable, :no_index

      def boolean_options_string
        %i(sortable no_index).map do |option|
          if ActiveRecord::Type::Boolean.new.cast(send(option))
            [option.to_s.upcase.split("_").join]
          end
        end.compact
      end
    end
  end
end
