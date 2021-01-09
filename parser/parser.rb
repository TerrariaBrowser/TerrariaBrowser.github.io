require 'htmlentities'

module Terraria
  class Parser
    def initialize(markup)
      @markup = markup
    end

    def parse_items
      @markup.uniq! { |i| i['itemid'] }
      htmlentities = HTMLEntities.new

      @markup.map do |item|
        # Delete empty entries
        item = item.delete_if { |k, v| v.nil? || v.to_s.empty? }

        %w(name damage sell buy tooltip critical buffduration damagetype knockback).each do |field|
          # Skip if not set
          next unless item.key? field

          # Process the item repeatedly until no HTML entities are left.
          until (decoded = htmlentities.decode item[field]) == item[field]
            item[field] = decoded
          end

          # Remove escape slashes
          item[field].gsub!('\\', '')

          # Remove handlebar style items, eg "Thing {{icon blah}}"
          item[field].gsub!(/\s{{.+?}}/, '')

          # Remove any HTML markup tags (bit hacky/primitive at the moment)
          item[field].gsub!(/<.+?>/, '')

          # Parse "[[File....|TITLE]]" things - assumes title is last param
          # item[field].gsub!(/\[\[.+?\|(.+?)\]\]/, '\1')
          item[field].gsub!(/\[\[File:[^\]]+\|([^\]]+?)\]\]/, '(\1)')
        end

        item['type'].map! { |t| t.capitalize }

        # TODO - need to parse the items attributes. Eg buy and sell value [[File..]] markdown for coin images/values. Or damage differences on platforms.
        item
      end
    end

    def parse_crafts
      pattern = Regexp.new "^{{crafts row.+?^}}$", Regexp::MULTILINE

      # TODO - version?
      craft_patterns =/^
      \s*  # Any line can optionally start with any number of whitespace (lazy)
      \|   # Pipe
      \s*  # Optional whitespace
      (?:  # Non-capturing group
        # Capture the "result"
        result\s*=\s*              # Match "result = " (with optional spacing around equals)
        (?<result>.+?)             # Capture what the result is into a named group. Shortest match.
        \s*\|\s*                   # Optional whitspaces around a pipe. This is usually the end of the line...
        (?<result_amount>\d+)?     # ... Except for when a result amount is provided
        (?<eicons>{{eicons.+?}})?  # ... or an "eicon"
      )?
      (?:
        # Capture the "tool"
        tool\s*=\s*              # Match "tool = " (with optional spacing around equals)
        (?<tool>.+?)             # Capture what the tool is into a named group. Shortest match.
      )?
      (?:
        # Capture the "ingredients"
        (?!result)                   # Ingredients never start with result (I dont think any items names begin with lowercase "result"?!)
        (?<ingredient>.+?)           # Now capture the ingredient into a named group. Lazy match any non-pipe characters (could this just be `.`?!)
        \s*\|\s*                     # Optional whitspaces around a pipe. This is usually the end of the line...
        (?<ingredient_amount>\d+?)?  # ... Unless it has an amount of the ingredient.
      )?
      $/mx

      @markup.scan(pattern).map do |crafts_row|
        item = {}

        crafts_row.each_line do |crafts_row_line|
          matches = craft_patterns.match crafts_row_line
          next if matches.nil?
          # puts matches.inspect

          matches_hash = matches.named_captures

          # Ingredients gets treated differently
          unless matches_hash['ingredient'].nil?
            matches_hash['ingredient_amount'] ||= 1
            item['ingredients'] ||= {}
            item['ingredients'][matches_hash['ingredient']] = matches_hash['ingredient_amount'].to_i
          else
            # Process result_amount
            if matches_hash.has_key? 'result_amount'
              # Defaults to 1
              matches_hash['result_amount'] ||= 1
              # ensure strings are ints.
              matches_hash['result_amount'] = matches_hash['result_amount'].to_i
            end

            # Combine this into the item
            item.merge! matches_hash.delete_if { |k, v| v.nil? }
          end
        end

        item
      end
    end
  end
end
