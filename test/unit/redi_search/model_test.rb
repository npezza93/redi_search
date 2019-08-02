# frozen_string_literal: true

require "test_helper"
require "active_record"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :characters do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :cars do |t|
  t.string :make
  t.string :model
end

class Character < ActiveRecord::Base
  redi_search schema: { name: :text }
end

class Car < ActiveRecord::Base
end

module RediSearch
  class ModelTest < Minitest::Test
    def setup
      @character = Character.new(name: :foo_bar)
    end

    def test_redi_search_document
      document = @character.redi_search_document
      assert_instance_of Document, document
      assert_equal "foo_bar", document.name
    end

    def test_redi_search_delete_document
      assert_respond_to @character, :redi_search_delete_document
      Character.redi_search_index.expects(:exist?).once.returns(true)
      Character.redi_search_index.expects(:del).once.returns(true)

      assert @character.redi_search_delete_document
    end

    def test_redi_search_add_document
      assert_respond_to @character, :redi_search_add_document
      Character.redi_search_index.expects(:exist?).once.returns(true)
      Character.redi_search_index.expects(:add).once.returns(true)

      assert @character.redi_search_add_document
    end

    def test_search_class_method
      assert_respond_to Character, :search
      Index.any_instance.expects(:search).once

      Character.search("foo")
    end

    def test_spellcheck_class_method
      assert_respond_to Character, :spellcheck
      Index.any_instance.expects(:spellcheck).once

      Character.spellcheck("foo")
    end

    def test_methods_arent_available_unless_redi_search_called
      car = Car.new
      refute_respond_to car, :redi_search_document
      refute_respond_to car, :redi_search_delete_document
      refute_respond_to car, :redi_search_add_document
    end

    def test_reindex
      Character.redi_search_index.expects(:reindex).once.returns(true)
      Character.redi_search_index.expects(:exist?).once.returns(true)
      Character.redi_search_index.expects(:add).once.returns(true)

      Character.create(name: :foo_bar)
      assert Character.reindex
    end
  end
end
