# frozen_string_literal: true

module RediSearch
  class Schema
    attr_reader :fields

    def initialize(&block)
      @fields = []

      instance_exec(&block)
    end

    def text_field(name, ...)
      self[name] || push(Schema::TextField.new(name, ...))
    end

    def numeric_field(name, ...)
      self[name] || push(Schema::NumericField.new(name, ...))
    end

    def tag_field(name, ...)
      self[name] || push(Schema::TagField.new(name, ...))
    end

    def geo_field(name, ...)
      self[name] || push(Schema::GeoField.new(name, ...))
    end

    def add_field(name, type, ...)
      case type
      when :text then method(:text_field)
      when :numeric then method(:numeric_field)
      when :tag then method(:tag_field)
      when :geo then method(:geo_field)
      end.call(name, ...)
    end

    def to_a
      fields.map(&:to_a).flatten
    end

    def [](name)
      fields.find { |field| field.name.to_sym == name.to_sym }
    end

    private

    def push(field)
      @fields.push(field)

      field
    end
  end
end
