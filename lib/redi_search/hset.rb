# frozen_string_literal: true

module RediSearch
  class Hset
    def initialize(index, document)
      @index = index
      @document = document
    end

    def call!
      RediSearch.client.call!(*command, skip_ft: true)
    end

    def call
      call!
    rescue RedisClient::CommandError
      false
    end

    private

    attr_reader :index, :document

    def command
      ["HSET", document.document_id, document.redis_attributes].compact
    end
  end
end
