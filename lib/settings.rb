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
  @@columns = {
    entity: :entity,
    attr: :attr,
    value: :value,
    json: :json
  }

  class << self
    def [] key
      fetch! if Time.now > @@expires
      @@cache[key]
    end

    def fetch!
      @@expires = Time.now + 300
      @@cache = {}
      @@model.all.each do |setting| 
        entity, attr, _ = raw_eav(setting)
        @@cache[entity.to_sym] ||= {}
        @@cache[entity.to_sym][attr.to_sym] = format_value_for(setting)
      end
    end

    def use_model model, opts={}
      @@model = model
      @@columns.merge! opts[:columns] if opts[:columns]
    end

    private

    def raw_eav setting
      [
        setting.send(@@columns[:entity]),
        setting.send(@@columns[:attr]),
        setting.send(@@columns[:value])
      ]
    end

    def format_value_for setting
      if setting.json
        return JSON.parse(setting.json, symbolize_names: true)
      end

      entity, attr, value = raw_eav(setting)
      
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
