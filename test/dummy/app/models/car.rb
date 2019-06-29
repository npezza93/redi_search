# frozen_string_literal: true

class Car < ApplicationRecord
  redi_search schema: { make: :text, model: :text }
end
