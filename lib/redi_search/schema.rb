# frozen_string_literal: true

require "redi_search/schema/geo_field"
require "redi_search/schema/numeric_field"
require "redi_search/schema/tag_field"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    def self.make_field(field_name, options)
      options = [options] if options.is_a? Symbol
      schema, options = options.to_a.flatten

      "RediSearch::Schema::#{schema.to_s.capitalize}Field".
        constantize.
        new(field_name, **options.to_h).
        to_a
    end

    def initialize(raw)
      @raw = raw
    end

    def to_a
      raw.map do |field_name, options|
        self.class.make_field(field_name, options)
      end.flatten
    end

    def fields
      raw.keys
    end

    def alter(field_name, options)
      raw[field_name] = options
      self
    end

    private

    attr_accessor :raw
  end
end
