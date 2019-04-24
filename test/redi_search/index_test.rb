# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class IndexTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("user_idx", name: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "#add" do
      record = User.create(name: Faker::Name.name)
      assert @index.add(record)
      assert_equal 1, @index.info["num_docs"].to_i
    end

    test "#search" do
      name = Faker::Name.name
      record = User.create(name: name)
      assert @index.add(record)
      assert_equal 1, @index.search(record.name.split(" ")[0]).first

      record_jr = User.create(name: name + " jr")
      assert @index.add(record_jr)
      assert_equal 2, @index.search(record.name.split(" ")[0]).first
    end

    test "#exists?" do
      assert @index.exist?
      assert @index.drop
      refute @index.exist?
    end
  end
end
