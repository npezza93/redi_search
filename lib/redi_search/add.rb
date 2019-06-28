# frozen_string_literal: true

module RediSearch
  class Add
    def initialize(index, document, score: 1.0)
      @index = index
      @document = document
      @score = score
    end

    def call!
      RediSearch.client.call!(
        "add",
        index.name,
        document.document_id,
        score,
        "replace",
        "fields",
        document.redis_attributes
      )
    end

    def call
      call!
    rescue Redis::CommandError
      false
    end

    private

    attr_reader :index, :document, :score
  end
end
