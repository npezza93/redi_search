# frozen_string_literal: true

module RediSearch
  class Schema
    attr_reader :fields

    def initialize(&block)
      @fields = []

      instance_exec(&block)
    end

    def text_field(name, **options, &block)
      self[name] || push(Schema::TextField.new(name, **options, &block))
    end

    def vector_field(name, **options, &block)
      self[name] || push(Schema::VectorField.new(name, **options, &block))
    end    

    def numeric_field(name, **options, &block)
      self[name] || push(Schema::NumericField.new(name, **options, &block))
    end

    def tag_field(name, **options, &block)
      self[name] || push(Schema::TagField.new(name, **options, &block))
    end

    def geo_field(name, **options, &block)
      self[name] || push(Schema::GeoField.new(name, **options, &block))
    end

    def add_field(name, type, **options, &block)
      case type
      when :text then method(:text_field)
      when :vector then method(:vector_field)
      when :numeric then method(:numeric_field)
      when :tag then method(:tag_field)
      when :geo then method(:geo_field)
      end.call(name, **options, &block)
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
