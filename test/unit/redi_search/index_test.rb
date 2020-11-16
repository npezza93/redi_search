# frozen_string_literal: true

require "test_helper"

module RediSearch
  class IndexTest < Minitest::Test # rubocop:disable Metrics/ClassLength
    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @user = User.new(rand, "foo", "bar")
      @document = Document.for_object(@index, @user)
    end

    def test_search
      assert_instance_of Search, @index.search(:foo)
    end

    def test_spellcheck
      assert_instance_of Spellcheck, @index.spellcheck(:foo)
    end

    def test_create
      Create.any_instance.expects(:call).once

      @index.create
    end

    def test_create!
      Create.any_instance.expects(:call!).once

      @index.create!
    end

    def test_drop_while_keeping_docs
      mock_client(%w(DROPINDEX users), "OK") do
        assert @index.drop(keep_docs: true)
      end
    end

    def test_drop
      mock_client(%w(DROPINDEX users DD), "OK") do
        assert @index.drop
      end
    end

    def test_drop_failure
      mock_exceptional_client do
        refute @index.drop
      end
    end

    def test_drop!
      mock_client(%w(DROPINDEX users DD), "OK") do
        assert @index.drop!
      end
    end

    def test_falure_drop!
      mock_exceptional_client do
        assert_raises Redis::CommandError do
          @index.drop!
        end
      end
    end

    def test_add
      Hset.any_instance.expects(:call).once

      @index.add(@document)
    end

    def test_add!
      Hset.any_instance.expects(:call!).once

      @index.add!(@document)
    end

    def test_multiple!
      document2 = Document.for_object(@index, User.new(rand, "bar", "baz"))
      Redis.new.stub(:call, "OK") do |redis|
        RediSearch.stub(:client, Client.new(redis)) do
          assert @index.add_multiple([@document, document2])
        end
      end
    end

    def test_del
      @document.expects(:del).once.returns(true)

      @index.del(@document)
    end

    def test_exists?
      mock_client(%w(INFO users), ["stuff"]) do
        assert @index.exist?
      end
    end

    def test_exists_when_index_doesnt_exist
      mock_client(%w(INFO users), "") do
        refute @index.exist?
      end
    end

    def test_exist_failure
      mock_exceptional_client do
        refute @index.exist?
      end
    end

    def test_info
      mock_client(%w(INFO users), %w(foo bar baz temp)) do
        info = @index.info
        assert_equal "bar", info.foo
        assert_equal "temp", info.baz
      end
    end

    def test_info_failure
      mock_exceptional_client do
        assert_nil @index.info
      end
    end

    def test_fields
      assert_equal %w(first last), @index.fields
    end

    def test_reindex
      @index.expects(:exist?).once.returns(true)
      @index.expects(:create).never
      @index.expects(:add_multiple).once

      @index.reindex([@document])
    end

    def test_reindex_when_index_doesnt_exist
      @index.expects(:exist?).once.returns(false)
      @index.expects(:create).once
      @index.expects(:add_multiple).once

      @index.reindex([@document])
    end

    def test_reindex_when_index_is_recreated
      @index.expects(:drop).once
      @index.expects(:exist?).once.returns(false)
      @index.expects(:create).once
      @index.expects(:add_multiple).once

      @index.reindex([@document], recreate: true)
    end

    def test_document_count
      mock_client(%w(INFO users), %w(num_docs 2)) do
        assert_equal 2, @index.document_count
      end
    end

    def test_add_field
      AddField.any_instance.expects(:call!).once

      @index.add_field(:foo, :text)
    end

    private

    def mock_client(expected_command, expected_response)
      client = Minitest::Mock.new.expect(
        :call!, Client::Response.new(expected_response), expected_command
      )

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end

    def mock_exceptional_client
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        RediSearch.stub(:client, client) { yield }
      end
    end
  end
end
