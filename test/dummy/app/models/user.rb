# frozen_string_literal: true

class User < ApplicationRecord
  include RediSearch

  searchable schema: { name: :text }
end
