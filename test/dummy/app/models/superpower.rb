# frozen_string_literal: true

class Superpower < ApplicationRecord
  redi_search schema: { power: :text }, index_prefix: :example
end
