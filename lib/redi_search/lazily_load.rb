# frozen_string_literal: true

module RediSearch
  module LazilyLoad
    extend Forwardable

    include Enumerable

    def_delegators :to_a, :size, :each, :last, :[]# , :empty?

    def loaded?
      @loaded = false unless defined? @loaded

      @loaded
    end

    def to_a
      execute unless loaded?

      documents
    end

    alias load to_a

    def inspect
      execute_and_rescue_inspection do
        return super unless valid?

        documents
      end
    end

    #:nocov:
    def pretty_print(printer)
      execute_and_rescue_inspection do
        return super(inspect) unless valid?

        printer.pp(documents)
      end
    end
    #:nocov:

    def count
      to_a.size
    end

    private

    attr_reader :documents

    def command
      raise NotImplementedError, "included class did not define #{__method__}"
    end

    def execute
      return unless valid?

      @loaded = true

      call!.yield_self do |response|
        parse_response(response)
      end
    end

    def call!
      RediSearch.client.call!(*command)
    end

    def parse_response(_response)
      raise NotImplementedError, "included class did not define #{__method__}"
    end

    def valid?
      true
    end

    def execute_and_rescue_inspection
      execute unless loaded?

      yield
    rescue Redis::CommandError => e
      e.message
    end
  end
end
