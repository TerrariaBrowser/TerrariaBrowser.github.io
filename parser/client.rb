require 'faraday'
require 'faraday_middleware'
require 'json'

module Terraria
  class Client
    # buff
    # buffduration
    # idwall
    # idtile
    ITEM_FIELDS = %w(
      itemid
      name
      damage
      damagetype
      autoswing
      pick
      axe
      hammer
      bait
      knockback
      placeable
      placedwidth
      placedheight
      stack
      mana
      tooltip
      consumable
      critical
      rare
      usetime
      toolspeed
      buy
      sell
      hardmode
      type
    )

    def initialize(middleware_type = nil)
      @connection = Faraday.new(url: 'https://terraria.gamepedia.com/') do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.response middleware_type unless middleware_type.nil?
        faraday.adapter Faraday.default_adapter
      end
    end

    def get_items
      @connection.get '/index.php', {
        'title' => 'Special:CargoExport',
        'tables' => 'Items',
        'fields' => ITEM_FIELDS.join(','),
        'order by' => 'itemid',
        'limit' => 10000,
        'format' => 'json'
      }
    end

    # section could be "Iron_Anvil"
    def get_recipes(section)
      # Example: https://terraria.gamepedia.com/index.php?title=Recipes/Iron_Anvil&action=raw
      @connection.get '/index.php', {
        'title' => "Recipes/#{section}",
        'action' => 'raw'
      }
    end

  end
end
