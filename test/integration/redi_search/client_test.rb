# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ClientTest < Minitest::Test
    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_pipelined
      assert(RediSearch.client.pipelined do
        @index.add(Document.for_object(@index, users(index: 0)))
        @index.add(Document.for_object(@index, users(index: 1)))
      end.ok?)
    end
  end
end
