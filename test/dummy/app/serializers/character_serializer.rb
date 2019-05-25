# frozen_string_literal: true

class CharacterSerializer
  def initialize(object)
    @object = object
  end

  def name
    "#{object.first} #{object.last}"
  end

  private

  attr_reader :object
end
