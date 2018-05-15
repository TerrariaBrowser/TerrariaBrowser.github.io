module Terraria
  class Parser
    def initialize(markup)
      @markup = markup
    end

    def parse_items
      # TODO - need to parse the markup (items)
      # pp @markup
      return @markup.uniq { |i| i['itemid'] }
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

      v = @markup.scan(pattern).map do |crafts_row|
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
