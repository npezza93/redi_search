# frozen_string_literal: true

require "faker"

User.insert_all(
  Array.new(10_000).map do
    { first: Faker::Name.first_name, last: Faker::Name.last_name }
  end
)

Character.insert_all(
  Array.new(500).map do
    { first: Faker::TvShows::GameOfThrones.dragon }
  end
)

Character.insert_all(
  Array.new(10_000).map do
    Faker::TvShows::GameOfThrones.character.yield_self do |character|
      { first: character.split(" ")[0],
        last: character.split(" ")[1..-1].join(" ") }
    end
  end
)

Character.reindex
User.reindex
