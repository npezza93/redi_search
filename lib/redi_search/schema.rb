# frozen_string_literal: true

require "redi_search/schema/geo_field"
require "redi_search/schema/numeric_field"
require "redi_search/schema/tag_field"
require "redi_search/schema/text_field"

module RediSearch
  class Schema
    def initialize(&block)
      @fields = []

      instance_exec self, &block
    end

    def text_field(name, **options, &block)
      self[name] ||
        @fields.push(Schema::TextField.new(name, **options, &block))
    end

    def numeric_field(name, **options, &block)
      self[name] ||
        @fields.push(Schema::NumericField.new(name, **options, &block))
    end

    def tag_field(name, **options, &block)
      self[name] || @fields.push(Schema::TagField.new(name, **options, &block))
    end

    def geo_field(name, **options, &block)
      self[name] || @fields.push(Schema::GeoField.new(name, **options, &block))
    end

    def to_a
      fields.map(&:to_a).flatten
    end

    def [](name)
      fields.find { |field| field.name == name }
    end

    attr_reader :fields
  end
end
