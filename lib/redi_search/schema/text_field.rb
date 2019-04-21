# frozen_string_literal: true

require "active_record/type"

module RediSearch
  class Schema
    class TextField
      def initialize(name, weight: 1.0, phonetic: nil, sortable: false,
                     no_index: false, no_stem: false)
        @name = name
        @weight = weight
        @phonetic = phonetic
        @sortable = sortable
        @no_index = no_index
        @no_stem = no_stem
      end

      def to_a
        query = [name.to_s, "TEXT"]
        query += boolean_options_string
        query += ["WEIGHT", weight] if weight
        query += ["PHONETIC", phonetic] if phonetic

        query
      end

      private

      attr_reader :name, :weight, :phonetic, :sortable, :no_index, :no_stem

      def boolean_options_string
        %i(sortable no_index no_stem).map do |option|
          if ActiveRecord::Type::Boolean.new.cast(send(option))
            option.to_s.upcase.split("_").join
          end
        end.compact
      end
    end
  end
end
