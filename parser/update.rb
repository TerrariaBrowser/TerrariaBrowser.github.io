require 'pp'
require 'json'

require './client'
require './parser'

# Get items
puts "Fetching Items..."
items = Terraria::Client.new(:json).get_items.body
puts "Got #{items.length} items... Parsing... "
parsed = Terraria::Parser.new(items).parse_items
puts "Parsing done. Saving #{parsed.length} items."
File.open("items.json", "w") do |f|
  f.write(parsed.to_json)
end
puts "Done!"
puts "\n\n---\n\n"

exit

# Get Stations
STATIONS=%w(
  By_Hand
  Work_Bench
  Furnace
  Iron_Anvil
  Hellforge
  Sawmill
  Loom
  Cooking_Pot
  Tinkerer's_Workshop
  Imbuing_Station
  Dye_Vat
  Keg
  Heavy_Work_Bench
  Blend-O-Matic
  Meat_Grinder
  Bone_Welder
  Glass_Kiln
  Honey_Dispenser
  Ice_Machine
  Living_Loom
  Sky_Mill
  Solidifier
  Flesh_Cloning_Vat
  Lihzahrd_Furnace
  Steampunk_Boiler
  Campfire
  Bookcase
  Crystal_Ball
  Autohammer
  Ancient_Manipulator
)

recipes = []

STATIONS.each do |station|
  puts "#{station} : Fetching..."
  markup = client.get_recipes(station).body
  puts "#{station} : Parsing..."
  parsed = Terraria::Parser.new(markup).parse_crafts

  parsed.map! { |item| item.merge('station' => station) }

  recipes.push *parsed

  puts "#{station} : Finished #{parsed.length}"
end

puts "Finished. Total recipes: #{recipes.length}"
puts "Saving..."
File.open("recipes.json", "w") do |f|
  f.write(parsed.to_json)
end
puts "Done!"
puts "\n\n---\n\n"

# pp recipes