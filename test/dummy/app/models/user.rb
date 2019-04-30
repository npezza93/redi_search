# frozen_string_literal: true

class User < ApplicationRecord
  redi_search schema: { first: :text, last: :text }

  def score
    1.0
  end
end
