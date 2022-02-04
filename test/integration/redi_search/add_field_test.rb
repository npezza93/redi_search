# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AddFieldTest < Minitest::Test
    def setup
      @index = Index.new(:cars) do
        text_field :make
      end.tap(&:create)
    end

    def teardown
      @index.drop
    end

    def test_adds_document_to_index
      assert AddField.new(@index, :model, :text).call
      assert_includes @index.fields, "model"
    end
  end
end
