# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AlterTest < Minitest::Test
    def setup
      @index = Index.new(:cars, make: :text)
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_adds_document_to_index
      assert Alter.new(@index, :model, :text).call
      assert_includes @index.fields, "model"
    end
  end
end
