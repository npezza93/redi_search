# frozen_string_literal: true

if ENV["COV"]
  require "simplecov"

  SimpleCov.start do
    enable_coverage :branch
    add_filter "/test/"
  end
end

require "minitest/autorun"
require "minitest/pride"
require "mocha/minitest"
require "redi_search"
require "debug"

require "active_support/testing/assertions"

User = Struct.new(:id, :first, :last) # rubocop:disable Lint/StructNewOverride

def users(index:)
  @users ||= Array.new(10).map.with_index(1) do |_el, i|
    User.new(i, "first_name#{i}", "last_name#{i}")
  end

  @users[index]
end
