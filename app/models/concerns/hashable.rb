require 'active_support/concern'

module Hashable
  extend ActiveSupport::Concern

  class_methods do
    def param_merge(params:, dig_set:, keys:[])
      dig_keys, dig_values = dig_set[0], dig_set[1]
      dig_keys.each_with_index do |k, i|
        if !params.dig(*keys.append(k))
          if params.has_key?(dig_keys[0])
            keys[0..i-1].inject(params, :fetch)[k] = dig_values[i]
          else
            params[k] = dig_values[i]
          end
        end
      end
      params
    end

    def dig_set(k:, v: nil, dig_keys: [])
      return [[k],[v]] if k && dig_keys.one? && k == dig_keys[0] || k && dig_keys.none?
      dig_keys.map{|key| [key, {}]}.append([k,v]).transpose
    end
  end
end
