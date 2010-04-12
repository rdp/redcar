
require 'textmate/bundle'
require 'textmate/environment'
require 'textmate/plist'
require 'textmate/preference'
require 'textmate/snippet'

module Redcar
  module Textmate
    def self.all_bundle_paths
      Dir[File.join(Redcar.root, "textmate", "Bundles", "*")]
    end
    
    def self.uuid_hash
      @uuid_hash ||= begin
        h = {}
        all_bundles.each do |b|
          h[b.uuid] = b
          b.snippets.each {|s| h[s.uuid] = s }
          b.preferences.each {|p| h[p.uuid] = p }
        end
        h
      end
    end
    
    def self.all_bundles
      @all_bundles ||= begin
        cache = PersistentCache.new("textmate_bundles")
        cache.cache do
          all_bundle_paths.map {|path| Bundle.new(path) }
        end
      end
    end
    
    def self.all_snippets
      @all_snippets ||= begin
        all_bundles.map {|b| b.snippets }.flatten
      end
    end
    
    def self.all_settings
      @all_settings ||= begin
        all_bundles.map {|b| b.preferences }.flatten.map {|p| p.settings}.flatten
      end
    end
    
    # Translates a Textmate key equivalent into a Redcar
    # keybinding. 
    def self.translate_key_equivalent(keyeq, name=nil)
      if keyeq
        key_str      = keyeq[-1..-1]
        case key_str
        when "\n"
          letter = "Return"
        else
          letter = key_str.gsub("\e", "Escape")
        end
        modifier_str = keyeq[0..-2]
        modifiers = modifier_str.split("").map do |modchar|
          case modchar
          when "^" # TM: Control
            [2, "Ctrl"]
          when "~" # TM: Option
            [3, "Alt"]
          when "@" # TM: Command
            [1, "Super"]
          when "$"
            [4, "Shift"]
          else
            return nil
          end
        end
        if letter =~ /^[[:alpha:]]$/ and letter == letter.upcase
          modifiers << [4, "Shift"]
        end
        modifiers = modifiers.sort_by {|a| a[0]}.map{|a| a[1]}.uniq
        res = if modifiers.empty?
          letter
        else
          modifiers.join("+") + "+" + (letter.length == 1 ? letter.upcase : letter)
        end
        res
      end
    end
  end
end





