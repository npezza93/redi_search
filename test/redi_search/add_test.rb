# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class AddTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new("users_test", first: :text, last: :text)
      @index.drop
      @index.create
      @document = RediSearch::Document.for_object(@index, users(index: 0))
    end

    def teardown
      @index.drop
    end

    def test_adds_document_to_index
      adder = RediSearch::Add.new(@index, @document)

      assert_difference -> { @index.document_count }, 1 do
        adder.call
      end
    end

    def test_if_call_fails_false_is_returned
      adder = RediSearch::Add.new(@index, @document)
      adder.stubs(:call!).raises(Redis::CommandError)

      assert_no_difference -> { @index.document_count }, 1 do
        refute adder.call
      end
    end

    def test_all_bang_raises_the_error_to_the_consumer
      adder = RediSearch::Add.new(@index, @document)
      RediSearch::Client.any_instance.stubs(:call!).raises(Redis::CommandError)

      assert_raises Redis::CommandError do
        adder.call!
      end
    end

    def test_validation_fails_if_score_is_not_correct
      ["thing", -1, 1.5].each do |score|
        adder = RediSearch::Add.new(@index, @document, score: score)

        assert_raises RediSearch::ValidationError do
          adder.call
        end
      end
    end

    def test_partially_replaces_document
      adder = RediSearch::Add.new(@index, @document, replace: { partial: true })

      assert_difference -> { @index.document_count }, 1 do
        adder.call
      end
    end

    def test_does_not_save_document
      adder = RediSearch::Add.new(@index, @document, no_save: true)

      assert_difference -> { @index.document_count }, 1 do
        adder.call
      end
    end
  end
end
