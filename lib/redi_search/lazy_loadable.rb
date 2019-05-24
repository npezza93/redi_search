# frozen_string_literal: true

module RediSearch
  module LazyLoadable
    def loaded?
      @loaded || false
    end

    def to_a
      execute unless loaded?

      @documents
    end

    #:nocov:
    def pretty_print(printer)
      execute unless loaded?

      printer.pp(documents)
    rescue Redis::CommandError => e
      printer.pp(e.message)
    end
    #:nocov:

    private

    def execute
      @loaded = true

      RediSearch.client.call!(*command).yield_self do |response|
        parse_response(response)
      end
    end

    def parse_response(_response)
      raise NotImplementedError
    end
  end
end
