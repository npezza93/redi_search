# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class CreateTest < ActiveSupport::TestCase
    setup do
      @index = Index.new(:users_test, first: :text, last: :text)
      @document = RediSearch::Document.for_object(@index, users(:user1))
    end

    teardown do
      @index.drop
    end

    test "creates index" do
      creator = RediSearch::Create.new(@index, @index.schema, {})

      assert_not @index.exist?
      assert creator.call
      assert @index.exist?
    end

    test "if call fails false is returned" do
      creator = RediSearch::Create.new(@index, @index.schema, {})
      creator.stubs(:call!).raises(Redis::CommandError)

      assert_not @index.exist?
      assert_not creator.call
      assert_not @index.exist?
    end

    test "#call! raises the error to the consumer" do
      creator = RediSearch::Create.new(@index, @index.schema, {})
      RediSearch::Client.any_instance.stubs(:call!).raises(Redis::CommandError)

      assert_raises Redis::CommandError do
        creator.call!
      end
    end

    test "max_text_fields option" do
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

    test "no_offsets option" do
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

    test "temporary option" do
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

    test "no_highlight option" do
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

    test "no_fields option" do
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

    test "no_frequencies option" do
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
