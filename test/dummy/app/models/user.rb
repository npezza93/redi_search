# frozen_string_literal: true

class User < ApplicationRecord
  redi_search schema: { name: :text }

  def score
    1.0
  end
end
