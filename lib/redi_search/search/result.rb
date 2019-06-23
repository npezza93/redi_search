# frozen_string_literal: true

module RediSearch
  class Search
    class Result < Array
      def initialize(index, used_clauses, count, documents)
        @count = count
        @used_clauses = used_clauses

        super(transform_response_to_documents(index, documents))
      end

      def count
        @count || super
      end

      def size
        @count || super
      end

      private

      def transform_response_to_documents(index, documents)
        documents.each_slice(response_slice).map do |slice|
          document_id = slice[0]
          fields = slice.last unless no_content?

          Document.new(index, document_id, Hash[*fields.to_a])
        end
      end

      def response_slice
        slice_length = 2
        slice_length -= 1 if no_content?

        slice_length
      end

      def no_content?
        @used_clauses.include? "no_content"
      end
    end
  end
end
