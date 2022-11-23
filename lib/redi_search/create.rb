# frozen_string_literal: true

module RediSearch
  class Create
    OPTION_MAPPER = {
      max_text_fields: "MAXTEXTFIELDS",
      no_offsets: "NOOFFSETS",
      no_highlight: "NOHL",
      no_fields: "NOFIELDS",
      no_frequencies: "NOFREQS"
    }.freeze

    def initialize(index, schema, options)
      @index = index
      @schema = schema
      @options = options
    end

    def call!
      RediSearch.client.call!(*command).ok?
    end

    def call
      call!
    rescue RedisClient::CommandError
      false
    end

    private

    attr_reader :index, :schema, :options

    def command
      ["CREATE", index.name, "ON", "HASH", "PREFIX", 1, index.name,
       *extract_options.compact, "SCHEMA", schema.to_a]
    end

    def extract_options
      options.map do |clause, switch|
        next unless OPTION_MAPPER.key?(clause.to_sym) && switch

        OPTION_MAPPER[clause.to_sym]
      end + temporary_option
    end

    def temporary_option
      return [] unless options[:temporary]

      ["TEMPORARY", options[:temporary]]
    end
  end
end
