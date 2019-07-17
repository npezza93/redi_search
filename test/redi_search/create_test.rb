# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class CreateTest < Minitest::Test
    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
      @document = RediSearch::Document.for_object(@index, users(:user1))
    end

    def teardown
      @index.drop
    end

    def test_creates_index
      creator = RediSearch::Create.new(@index, @index.schema, {})

      assert_not @index.exist?
      assert creator.call
      assert @index.exist?
    end

    def test_if_call_fails_false_is_returned
      creator = RediSearch::Create.new(@index, @index.schema, {})
      creator.stubs(:call!).raises(Redis::CommandError)

      assert_not @index.exist?
      assert_not creator.call
      assert_not @index.exist?
    end

    def test_call_bang_raises_the_error_to_the_consumer
      creator = RediSearch::Create.new(@index, @index.schema, {})
      RediSearch::Client.any_instance.stubs(:call!).raises(Redis::CommandError)

      assert_raises Redis::CommandError do
        creator.call!
      end
    end

    def test_max_text_fields_option
      creator = RediSearch::Create.new(
        @index, @index.schema, max_text_fields: true
      )

      assert_not @index.exist?
      assert creator.call!
      assert_includes(
        @index.info.index_options,
        RediSearch::Create::OPTION_MAPPER[:max_text_fields]
      )
      assert @index.exist?
    end

    def test_no_offsets_option
      creator = RediSearch::Create.new(
        @index, @index.schema, no_offsets: true
      )

      assert_not @index.exist?
      assert creator.call!
      assert_includes(
        @index.info.index_options,
        RediSearch::Create::OPTION_MAPPER[:no_offsets]
      )
      assert @index.exist?
    end

    def test_temporary_option
      creator = RediSearch::Create.new(
        @index, @index.schema, temporary: 2000
      )

      assert_not @index.exist?
      assert creator.call!
      # assert_includes(
      #   @index.info.index_options,
      #   RediSearch::Create::OPTION_MAPPER[:temporary]
      # )
      assert @index.exist?
    end

    def test_no_highlight_option
      creator = RediSearch::Create.new(
        @index, @index.schema, no_highlight: true
      )

      assert_not @index.exist?
      assert creator.call!
      # assert_includes(
      #   @index.info.index_options,
      #   RediSearch::Create::OPTION_MAPPER[:no_highlight]
      # )
      assert @index.exist?
    end

    def test_no_fields_option
      creator = RediSearch::Create.new(
        @index, @index.schema, no_fields: true
      )

      assert_not @index.exist?
      assert creator.call!
      assert_includes(
        @index.info.index_options,
        RediSearch::Create::OPTION_MAPPER[:no_fields]
      )
      assert @index.exist?
    end

    def test_no_frequencies_option
      creator = RediSearch::Create.new(
        @index, @index.schema, no_frequencies: true
      )

      assert_not @index.exist?
      assert creator.call!
      assert_includes(
        @index.info.index_options,
        RediSearch::Create::OPTION_MAPPER[:no_frequencies]
      )
      assert @index.exist?
    end
  end
end
