# frozen_string_literal: true

require "redi_search/schema/geo_field"
require "redi_search/schema/numeric_field"
require "redi_search/schema/tag_field"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    def initialize(schema_hash)
      @schema_hash = schema_hash
    end

    def to_a
      schema_hash.map do |field_name, options|
        options = [options] if options.is_a? Symbol
        schema, options = options.to_a.flatten

        "RediSearch::Schema::#{schema.to_s.capitalize}Field".
          constantize.
          new(field_name, **options.to_h).
          to_a
      end.flatten
    end

    private

    attr_reader :schema_hash
  end
end
