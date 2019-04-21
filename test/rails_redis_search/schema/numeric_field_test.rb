# frozen_string_literal: true

require "test_helper"
require "rails_redis_search/schema/numeric_field"

module RailsRedisSearch
  class Schema
    class NumericFieldTest < ActiveSupport::TestCase
      test "default options" do
        schema = RailsRedisSearch::Schema::NumericField.new("temp_field")
        assert_equal "temp_field NUMERIC", schema.to_s
      end

      test "sortable option" do
        schema = RailsRedisSearch::Schema::NumericField.new(
          "temp_field", sortable: true
        )
        assert_equal "temp_field NUMERIC SORTABLE", schema.to_s
      end

      test "no_index option" do
        schema = RailsRedisSearch::Schema::NumericField.new(
          "temp_field", no_index: true
        )
        assert_equal "temp_field NUMERIC NOINDEX", schema.to_s
      end

      test "both options" do
        schema = RailsRedisSearch::Schema::NumericField.new(
          "temp_field", no_index: true, sortable: true
        )
        assert_equal "temp_field NUMERIC SORTABLE NOINDEX", schema.to_s
      end
    end
  end
end
