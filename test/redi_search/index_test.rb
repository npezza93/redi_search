# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class IndexTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("user_idx", first: :text, last: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "#add" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record)
      assert_equal 1, @index.info["num_docs"].to_i
    end

    test "#search" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record)
      assert_equal 1, @index.search(record.first).count

      record_jr = record.dup
      record_jr.last = record_jr.last + " jr"
      record_jr.save
      assert @index.add(record_jr)
      assert_equal 2, @index.search(record.first).count
    end

    test "#exists?" do
      assert @index.exist?
      assert @index.drop
      refute @index.exist?
    end
  end
end
