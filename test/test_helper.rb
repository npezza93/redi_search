# frozen_string_literal: true

if ENV["COV"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/test/"
  end
end

require "minitest"
require "minitest/pride"
require "pry"
require "faker"
require "mocha/minitest"
require "redi_search"

require "active_support/testing/assertions"

ENV["RAILS_ENV"] = "test"

# require_relative "../test/dummy/config/environment"
# ActiveRecord::Migrator.migrations_paths =
#   [File.expand_path("../test/dummy/db/migrate", __dir__)]
# require "rails/test_help"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = "bin/test"

# if ActiveSupport::TestCase.respond_to?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = Rails.root.join("test", "fixtures")
#   ActiveSupport::TestCase.fixtures :all
# end

User = Struct.new(:id, :first, :last)

def users(index:)
  @users ||= Array.new(10).map.with_index(1) do |_el, i|
    User.new(i, "first_name#{i}", "last_name#{i}")
  end

  @users[index]
end
