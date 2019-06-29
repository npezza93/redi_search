# frozen_string_literal: true

module RediSearch
  class Add
    include ActiveModel::Validations

    validates :score, numericality: {
      greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0
    }

    def initialize(index, document, score: 1.0, **options)
      @index = index
      @document = document
      @score = score || 1.0
      @options = options
    end

    def call!
      validate!

      RediSearch.client.call!(*command).ok?
    end

    def call
      call!
    rescue Redis::CommandError
      false
    end

    private

    attr_reader :index, :document, :score, :options

    def command
      [
        "ADD",
        index.name,
        document.document_id,
        score,
        *extract_options,
        "FIELDS",
        document.redis_attributes
      ].compact
    end

    def extract_options
      opts = []
      opts << "NOSAVE" if options[:no_save]
      opts
    end
  end
end
