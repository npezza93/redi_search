# frozen_string_literal: true

require "test_helper"

module RediSearch
  class CreateTest < Minitest::Test
    def setup
      @index = Index.new(:users) do
        text_field :first
        text_field :last
      end

      refute_predicate @index, :exist?
    end

    def teardown
      @index.drop
    end

    def test_creates_index
      assert Create.new(@index, @index.schema, {}).call
      assert_predicate @index, :exist?
    end

    def test_max_text_fields_option
      assert Create.new(@index, @index.schema, max_text_fields: true).call
      assert_predicate @index, :exist?
    end

    def test_no_offsets_option
      assert Create.new(@index, @index.schema, no_offsets: true).call
      assert_predicate @index, :exist?
    end

    def test_temporary_option
      assert Create.new(@index, @index.schema, temporary: 2000).call
      assert_predicate @index, :exist?
    end

    def test_no_highlight_option
      assert Create.new(@index, @index.schema, no_highlight: true).call
      assert_predicate @index, :exist?
    end

    def test_no_fields_option
      assert Create.new(@index, @index.schema, no_fields: true).call
      assert_predicate @index, :exist?
    end

    def test_no_frequencies_option
      assert Create.new(@index, @index.schema, no_frequencies: true).call
      assert_predicate @index, :exist?
    end

    def test_multiple_options
      assert Create.new(
        @index, @index.schema,
        no_highlight: true, no_fields: true, no_frequencies: true,
        temporary: 2000
      ).call
      assert_predicate @index, :exist?
    end
  end
end
