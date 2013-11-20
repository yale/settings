require "settings/version"
require 'json'

# General purpose read-only EAV settings cache
#
# Usage:
#
# Settings.set_model Setting #=> supports Sequel or AR model
# Settings[:entity][:attribute] #=> will refresh cache if past TTL
#
class Settings
  # Set initial expiry to epoch time
  @@expires = Time.now - Time.now.to_i
  @@cache = {}
  @@model = nil
  
  class << self
    def use_model model
      @@model = model
    end
    
    def fetch!
      @@expires = Time.now + 300
      @@cache = {}
      @@model.all.each do |setting| 
        entity, attr = setting.entity.to_sym, setting.attr.to_sym
        @@cache[entity] ||= {}
        @@cache[entity][attr] = format_value_for(setting)
      end
    end
    
    def [] key
      fetch! if Time.now > @@expires
      @@cache[key]
    end
    
  private

    def format_value_for setting
      if setting.json
        return JSON.parse(setting.json, symbolize_names: true)
      end
      entity, attr, value = setting.entity, setting.attr, setting.value
      # Coerce numeric values
      if value.is_numeric?
        value = Float(value)
        if value % 1 == 0
          value = value.to_i
        end
      end
      
      # Are we dealing with a boolean?
      attr[-1] == "?" ? value == 1 : value
    end
  end
end
