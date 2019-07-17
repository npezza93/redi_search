# frozen_string_literal: true

require "redis"
require "active_support/lazy_load_hooks"

require "redi_search/configuration"

require "redi_search/model"
require "redi_search/index"
require "redi_search/log_subscriber"
require "redi_search/document"

module RediSearch
  class << self
    extend Forwardable

    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def_delegator :configuration, :client

    def env
      @env ||= ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include RediSearch::Model
end
RediSearch::LogSubscriber.attach_to :redi_search
