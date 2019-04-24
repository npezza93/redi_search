# frozen_string_literal: true

module RediSearch
  class Result
    attr_reader :doc_id, :fields

    def initialize(doc_id, fields)
      @doc_id = doc_id
      @raw_fields = fields.in_groups(2).to_h
      @raw_fields.each do |field, value|
        define_singleton_method field do
          value
        end
      end
    end
  end
end
