# frozen_string_literal: true

class CharacterSerializer
  def initialize(object)
    @object = object
  end

  delegate :id, to: :object

  def name
    "#{object.first} #{object.last}"
  end

  private

  attr_reader :object
end
