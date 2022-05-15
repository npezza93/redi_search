# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ClientTest < Minitest::Test
    def setup
      @index = Index.new(:users) do
        text_field :first
        text_field :last
      end.tap(&:create)
    end

    def teardown
      @index.drop
    end

    def test_multi
      assert_predicate(RediSearch.client.multi do
        @index.add(Document.for_object(@index, users(index: 0)))
        @index.add(Document.for_object(@index, users(index: 1)))
      end, :ok?)
    end
  end
end
