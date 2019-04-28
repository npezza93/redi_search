# frozen_string_literal: true

require "redi_search/schema"
require "redi_search/error"
require "redi_search/search/query"
require "redi_search/result/collection"

module RediSearch
  class Index
    attr_reader :name, :schema

    def initialize(name, schema)
      @name = name
      @schema = schema
    end

    def search(query)
      Search::Query.new(self, query)
    end

    def create
      create!
    rescue Redis::CommandError
      false
    end

    def create!
      client.call!("CREATE", name, "SCHEMA", Schema.new(schema).to_a).ok?
    end

    def drop
      drop!
    rescue Redis::CommandError
      false
    end

    def drop!
      client.call!("DROP", name).ok?
    end

    def add(record, score = 1.0)
      add!(record, score)
    rescue Redis::CommandError
      false
    end

    def add!(record, score = 1.0)
      client.call!(
        "ADD", name, record.id, score, "REPLACE", "FIELDS",
        *fields.flat_map do |field|
          [field, record.public_send(field)]
        end
      )
    end

    def add_multiple!(records)
      client.pipelined do
        records.each do |record|
          add!(record)
        end
      end.ok?
    end

    def exist?
      !client.call!("INFO", name).empty?
    rescue Redis::CommandError
      false
    end

    def info
      Hash[*client.call!("INFO", name)]
    rescue Redis::CommandError
      nil
    end

    def fields
      @fields ||= info["fields"].map(&:first)
    end

    private

    def client
      RediSearch.client
    end
  end
end
