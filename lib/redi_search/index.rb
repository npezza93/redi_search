# frozen_string_literal: true

require "redi_search/schema"
require "redi_search/error"

module RediSearch
  class Index
    attr_reader :name, :schema

    def initialize(name, schema)
      @name = name
      @schema = schema
    end

    def search(query, **options)
      client.call!("SEARCH", query, *options.to_a.flatten)
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

    def add(records)
      add!(records)
    rescue Redis::CommandError
      false
    end

    def add!(record)
      client.call!(
        "ADD", name, record.id, record.score, "REPLACE", "FIELDS",
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
      client.call!("INFO", name)
    rescue Redis::CommandError
      nil
    end

    def fields
      @fields ||= begin
        info.to_a.then do |description|
          description[description.index("fields") + 1].map(&:first)
        end
      end
    end

    private

    def client
      RediSearch.client
    end
  end
end
