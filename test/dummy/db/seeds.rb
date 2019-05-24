# frozen_string_literal: true

require "faker"

10_000.times do
  User.create(first: Faker::Name.first_name, last: Faker::Name.last_name)
end

500.times do
  Character.create(first_name: Faker::TvShows::GameOfThrones.dragon)
end

4_000.times do
  Faker::TvShows::GameOfThrones.character.tap do |character|
    Character.create(
      first_name: character.split(" ")[0],
      last_name: character.split(" ")[1..-1].join(" ")
    )
  end
end
