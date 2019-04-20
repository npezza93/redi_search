# frozen_string_literal: true

class User < ApplicationRecord
  include RailsRedisSearch

  searchable schema: { name: "TEXT" }
end
