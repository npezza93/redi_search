# frozen_string_literal: true

module RediSearch
  class Schema
    class TagField < Field
      def initialize(name, separator: ",", sortable: false, no_index: false,
                     &block)
        @name        = name
        @separator   = separator
        @sortable    = sortable
        @no_index    = no_index
        @value_block = block
      end

      def to_a
        query = [name.to_s, "TAG"]
        query += ["SEPARATOR", separator] if separator
        query += boolean_options_string

        query
      end

      def coerce(value)
        value.join(separator)
      end

      def cast(value)
        value.split(separator)
      end

      def serialize(record)
        if value_block
          record.instance_exec(&value_block)
        else
          record.public_send(name)
        end.to_a
      end

      private

      attr_reader :separator, :sortable, :no_index

      def boolean_options
        %i(sortable no_index)
      end
    end
  end
end
