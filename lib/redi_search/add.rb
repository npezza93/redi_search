# frozen_string_literal: true

module RediSearch
  class Add
    def initialize(index, document, **options)
      @index = index
      @document = document
      @options = options
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
      ).ok?
    end

    def call
      call!
    rescue Redis::CommandError
      false
    end

    private

    attr_reader :index, :document, :options

    def score
      options[:score] || 1.0
    end
  end
end
