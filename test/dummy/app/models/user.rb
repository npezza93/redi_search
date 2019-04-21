# frozen_string_literal: true

class User < ApplicationRecord
  include RediSearch

  redi_search schema: { name: :text }
end
