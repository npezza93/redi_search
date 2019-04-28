# frozen_string_literal: true

module RediSearch
  class Result
    attr_reader :doc_id

    def initialize(doc_id, fields)
      @doc_id = doc_id
      @raw_fields = fields.in_groups_of(2).to_h

      @raw_fields.each do |field, value|
        instance_variable_set(:"@#{field}", value)
        define_singleton_method field do
          value
        end
      end
    end

    def inspect
      fields = @raw_fields.merge(doc_id: @doc_id).map do |name, value|
        if value.is_a? String
          "#{name}: \"#{value}\""
        else
          "#{name}: #{value}"
        end
      end.join(", ")

      "#<#{self.class} #{fields}>"
    end
  end
end
