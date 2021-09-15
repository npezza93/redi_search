# frozen_string_literal: true

module RediSearch
  class Search
    class Result
      extend Forwardable
      include Enumerable

      def initialize(search, count, documents)
        @count = count
        @search = search
        @results = parse_results(documents)
      end

      def count
        @count || results.count
      end

      def size
        @count || results.size
      end

      def_delegators :results, :each, :empty?, :[], :last

      def inspect
        results
      end

      # :nocov:
      def pretty_print(printer)
        printer.pp(results)
      end
      # :nocov:

      private

      attr_reader :results, :search

      def response_slice
        slice_length = 2
        slice_length -= 1 if no_content?
        slice_length += 1 if with_scores?

        slice_length
      end

      def with_scores?
        search.used_clauses.include? Search::Clauses::WithScores
      end

      def no_content?
        search.used_clauses.include? Search::Clauses::NoContent
      end

      def parse_results(documents)
        documents.each_slice(response_slice).map do |slice|
          document_id = slice[0]
          fields = slice.last unless no_content?
          score = slice[1].to_f if with_scores?

          Document.new(search.index, document_id, Hash[*fields.to_a], score)
        end
      end
    end
  end
end
