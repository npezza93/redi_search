# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module RediSearch
  class Result
    class Collection
      include Enumerable

      attr_reader :count, :records
      delegate :each, to: :records

      def initialize(index, count, records)
        @count = count
        @records = Hash[*records].map do |doc_id, fields|
          Document.new(index, doc_id, Hash[*fields])
        end
      end
    end
  end
end
