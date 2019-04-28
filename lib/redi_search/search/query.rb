# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module RediSearch
  module Search
    class Query
      include Enumerable

      attr_accessor :index, :query, :options

      def initialize(index, query)
        @index = index
        @query = query
        @loaded = false
        @options = []
      end

      def inspect
        execute unless loaded?

        "[#{@records.records.map(&:inspect).join(', ')}]"
      end

      def loaded?
        @loaded
      end

      def highlight
        options.push("HIGHLIGHT")

        self
      end

      def to_a
        execute unless loaded?

        @records
      end

      delegate :count, :each, to: :to_a

      private

      attr_reader :records

      def execute
        @loaded = true
        results = RediSearch.client.call!(
          "SEARCH", index.name, query, *options.flatten
        )

        @records = Result::Collection.new(results[0], results[1..-1])
      end
    end
  end
end
