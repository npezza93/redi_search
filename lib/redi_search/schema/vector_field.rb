# frozen_string_literal: true

module RediSearch
  class Schema
    class VectorField < Field
      def initialize(name, 
                     algorithm: "FLAT", 
                     count: 0, 
                     type: "FLOAT32", 
                     dim: 0, 
                     distance_metric: "COSINE", 
                     initial_cap: 0, 
                     block_size: 1024, 
                     sortable: false, 
                     no_index: false, &block)
        @name = name
        @value_block = block

        { algorithm: algorithm, count: count, type: type,
          dim: dim, distance_metric: distance_metric, initial_cap: initial_cap,
          block_size: block_size, sortable: sortable, 
          no_index: no_index }.each do |attr, value|
          instance_variable_set("@#{attr}", value)
        end
      end

      def to_a
        query = [name.to_s, "VECTOR"]
        query += [algorithm, count] if algorithm && count
        query += ["TYPE", type] if type
        query += ["DIM", dim] if dim
        query += ["DISTANCE_METRIC", distance_metric] if distance_metric
        query += ["INITIAL_CAP", initial_cap] if initial_cap
        query += ["BLOCK_SIZE", block_size] if block_size
        query += boolean_options_string

        query
      end

      private

      attr_reader :algorithm,
                  :count,
                  :type,
                  :dim,
                  :distance_metric,
                  :initial_cap,
                  :block_size,
                  :sortable, 
                  :no_index

      def boolean_options
        %i(sortable no_index)
      end
    end
  end
end
