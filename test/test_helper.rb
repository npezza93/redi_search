# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/test/"
end

require "minitest/pride"
require "pry"
require "faker"
require "mocha/minitest"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths =
  [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = "bin/test"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = Rails.root.join("test", "fixtures")
  ActionDispatch::IntegrationTest.fixture_path =
    ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end
