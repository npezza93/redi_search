# frozen_string_literal: true

require "redi_search/result"

module RediSearch
  class Result
    class Collection
      attr_reader :count, :records

      def initialize(count, records)
        @count = count
        @records = Hash[*records].map do |doc_id, fields|
          Result.new(doc_id, fields)
        end
      end
    end
  end
end
