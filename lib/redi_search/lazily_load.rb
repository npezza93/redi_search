# frozen_string_literal: true

module RediSearch
  module LazilyLoad
    extend ActiveSupport::Concern

    include Enumerable

    included do
      delegate :size, :each, to: :to_a
    end

    def loaded?
      @loaded = false unless defined? @loaded

      @loaded
    end

    def to_a
      execute unless loaded?

      @documents
    end

    alias load to_a

    #:nocov:
    def inspect
      execute unless loaded?

      to_a
    end

    def pretty_print(printer)
      execute unless loaded?

      printer.pp(documents)
    rescue Redis::CommandError => e
      printer.pp(e.message)
    end
    #:nocov:

    def count
      to_a.size
    end

    private

    def command
      raise NotImplementedError, "included class did not define #{__method__}"
    end

    def execute
      @loaded = true

      call!(*command).yield_self do |response|
        parse_response(response)
      end
    end

    def call!(*command)
      RediSearch.client.call!(*command)
    end

    def parse_response(_response)
      raise NotImplementedError, "included class did not define #{__method__}"
    end
  end
end
