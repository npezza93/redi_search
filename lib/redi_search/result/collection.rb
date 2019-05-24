# frozen_string_literal: true

module RediSearch
  class Result
    class Collection < Array
      def initialize(index, count, documents)
        @count = count
        super(Hash[*documents].map do |doc_id, fields|
          Document.new(index, doc_id, Hash[*fields])
        end)
      end

      def count
        @count || super
      end

      def size
        @count || super
      end
    end
  end
end
