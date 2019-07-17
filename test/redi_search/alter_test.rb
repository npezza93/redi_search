# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class AlterTest < Minitest::Test
    def setup
      Car.reindex
      @car = cars(:model_3)
    end

    def teardown
      Car.redi_search_index.drop
    end

    def test_alter_adds_a_new_field_to_the_index
      index = Car.redi_search_index

      assert_equal %w(make model), index.fields
      assert_not Car.search("3").first.respond_to? :color

      index.alter(:color, :text)
      assert_equal %w(make model color), index.fields
      index.add(Document.for_object(index, @car), replace: true)
      assert index.search("3").first.respond_to? :color
    end
  end
end
