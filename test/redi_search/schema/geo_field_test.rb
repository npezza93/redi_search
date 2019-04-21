# frozen_string_literal: true

require "test_helper"
require "redi_search/schema/geo_field"

module RediSearch
  class Schema
    class GeoFieldTest < ActiveSupport::TestCase
      test "default options" do
        schema = RediSearch::Schema::GeoField.new("temp_field")
        assert_equal "temp_field GEO", schema.to_s
      end

      test "sortable option" do
        schema = RediSearch::Schema::GeoField.new(
          "temp_field", sortable: true
        )
        assert_equal "temp_field GEO SORTABLE", schema.to_s
      end

      test "no_index option" do
        schema = RediSearch::Schema::GeoField.new(
          "temp_field", no_index: true
        )
        assert_equal "temp_field GEO NOINDEX", schema.to_s
      end

      test "both options" do
        schema = RediSearch::Schema::GeoField.new(
          "temp_field", no_index: true, sortable: true
        )
        assert_equal "temp_field GEO SORTABLE NOINDEX", schema.to_s
      end
    end
  end
end
