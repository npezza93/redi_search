# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "redi_search/search/query/highlight_clause"

module RediSearch
  module Search
    class Query
      include Enumerable

      attr_accessor :index, :query, :options, :command

      def initialize(index, query)
        @index = index
        @query = query
        @loaded = false
        @command = ["SEARCH", index.name, query]
      end

      def inspect
        execute unless loaded?

        "[#{@records.records.map(&:inspect).join(', ')}]"
      end

      def loaded?
        @loaded
      end

      def highlight(**options)
        command.push(*HighlightClause.new(**options).clause)

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

        RediSearch.client.call!(*command).then do |results|
          @records = Result::Collection.new(results[0], results[1..-1])
        end
      end
    end
  end
end
