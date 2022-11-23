# frozen_string_literal: true

module RediSearch
  class AddField
    def initialize(index, name, type, **options, &block)
      @index   = index
      @name    = name
      @type    = type
      @options = options
      @block   = block
    end

    def call!
      field = index.schema.add_field(name, type, **options, &block)

      RediSearch.client.call!("ALTER", index.name, "SCHEMA", "ADD", *field).ok?
    end

    def call
      call!
    rescue RedisClient::CommandError
      false
    end

    private

    attr_reader :index, :name, :type, :options, :block
  end
end
