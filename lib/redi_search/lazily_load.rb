# frozen_string_literal: true

module RediSearch
  module LazilyLoad
    extend ActiveSupport::Concern

    include Enumerable

    included do
      delegate :size, :count, :each, to: :to_a
    end

    def loaded?
      @loaded = false unless defined? @loaded

      @loaded
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

    def command
      raise NotImplementedError, "included class did not define #{__method__}"
    end

    def execute
      @loaded = true

      RediSearch.client.call!(*command).yield_self do |response|
        parse_response(response)
      end
    end

    def parse_response(_response)
      raise NotImplementedError, "included class did not define #{__method__}"
    end
  end
end
