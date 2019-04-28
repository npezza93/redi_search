# frozen_string_literal: true

require "redi_search/result"
require "active_support/core_ext/module/delegation"

module RediSearch
  class Result
    class Collection
      include Enumerable

      attr_reader :count, :records
      delegate :each, to: :records

      def initialize(count, records)
        @count = count
        @records = Hash[*records].map do |doc_id, fields|
          Result.new(doc_id, fields)
        end
      end
    end
  end
end
