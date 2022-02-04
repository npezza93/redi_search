# frozen_string_literal: true

module RediSearch
  class Index
    attr_reader :name, :schema, :model

    def initialize(name, model = nil, &schema)
      @name = name.to_s
      @schema = Schema.new(&schema)
      @model = model
    end

    def search(term = nil, **term_options)
      Search.new(self, term, **term_options)
    end

    def spellcheck(query, distance: 1)
      Spellcheck.new(self, query, distance: distance)
    end

    def create(**options)
      Create.new(self, schema, options).call
    end

    def create!(**options)
      Create.new(self, schema, options).call!
    end

    def drop(keep_docs: false)
      drop!(keep_docs: keep_docs)
    rescue Redis::CommandError
      false
    end

    def drop!(keep_docs: false)
      command = ["DROPINDEX", name]
      command << "DD" unless keep_docs
      client.call!(*command.compact).ok?
    end

    def add(document)
      Hset.new(self, document).call
    end

    def add!(document)
      Hset.new(self, document).call!
    end

    def add_multiple(documents)
      client.multi do
        documents.each do |document|
          add(document)
        end
      end.all? { |response| response >= 0 }
    end

    def del(document)
      document.del
    end

    def exist?
      !client.call!("INFO", name).empty?
    rescue Redis::CommandError
      false
    end

    def info
      hash = Hash[*client.call!("INFO", name)]
      info_struct = Struct.new(*hash.keys.map(&:to_sym))
      info_struct.new(*hash.values)
    rescue Redis::CommandError
      nil
    end

    def fields
      schema.fields.map { |field| field.name.to_s }
    end

    def reindex(documents, recreate: false)
      drop if recreate
      create unless exist?

      add_multiple documents
    end

    def document_count
      info.num_docs.to_i
    end

    def add_field(field_name, schema)
      AddField.new(self, field_name, schema).call!
    end

    private

    def client
      RediSearch.client
    end
  end
end
