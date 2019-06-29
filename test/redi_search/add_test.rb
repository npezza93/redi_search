# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class AddTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("users_test", first: :text, last: :text)
      @index.drop
      @index.create
      @document = RediSearch::Document.for_object(@index, users(:user1))
    end

    teardown do
      @index.drop
    end

    test "adds document to index" do
      adder = RediSearch::Add.new(@index, @document)

      assert_difference -> { @index.document_count }, 1 do
        adder.call
      end
    end

    test "if call fails false is returned" do
      adder = RediSearch::Add.new(@index, @document)
      adder.stubs(:call!).raises(Redis::CommandError)

      assert_no_difference -> { @index.document_count }, 1 do
        assert_not adder.call
      end
    end

    test "#call! raises the error to the consumer" do
      adder = RediSearch::Add.new(@index, @document)
      RediSearch::Client.any_instance.stubs(:call!).raises(Redis::CommandError)

      assert_raises Redis::CommandError do
        adder.call!
      end
    end

    test "validation fails if score is not correct" do
      ["thing", -1, 1.5].each do |score|
        adder = RediSearch::Add.new(@index, @document, score: score)

        assert_raises ActiveModel::ValidationError do
          adder.call
        end
      end
    end
  end
end
