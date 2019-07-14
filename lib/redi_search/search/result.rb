# frozen_string_literal: true

module RediSearch
  class Search
    class Result
      include Enumerable

      def initialize(index, used_clauses, count, documents)
        @count = count
        @used_clauses = used_clauses
        @results = parse_results(index, documents)
      end

      def count
        @count || results.count
      end

      def size
        @count || results.size
      end

      delegate :each, :empty?, to: :results

      #:nocov:
      def inspect
        results
      end

      def pretty_print(printer)
        printer.pp(results)
      end
      #:nocov:

      private

      attr_reader :results

      def response_slice
        slice_length = 2
        slice_length -= 1 if no_content?
        slice_length += 1 if with_scores?

        slice_length
      end

      def with_scores?
        @used_clauses.include? "with_scores"
      end

      def no_content?
        @used_clauses.include? "no_content"
      end

      def parse_results(index, documents)
        documents.each_slice(response_slice).map do |slice|
          document_id = slice[0]
          fields = slice.last unless no_content?
          score = slice[1].to_f if with_scores?

          Document.new(index, document_id, Hash[*fields.to_a], score)
        end
      end
    end
  end
end
