# frozen_string_literal: true

class User < ApplicationRecord
  redi_search schema: { name: :text }
end
