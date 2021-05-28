require 'active_support/concern'

module Hashable
  extend ActiveSupport::Concern

  class_methods do

    def case_merge(h, k, v, *dig_keys)
      puts "h: #{h}, k: #{k}, v: #{v}, dig_keys: #{dig_keys}"
      case
        when dig_keys.any?; nested_merge(h, k, v, dig_keys)
        when h.empty?; h.merge!({k=>v})
        #when h.keys.include?(k) && concat_arr?(h[k], v); h.merge!({k=>(h[k]+v)})
        when h.keys.include?(k) && h[k].is_a?(Array); h.merge!({k=>dig_val(v, h[k])}) # dig_val(v, h[k])
        when v.is_a?(Hash); infer_dig_keys_and_merge(h, k, v)
      end
    end

    def nested_merge(h, k, v, dig_keys)
      keys, vals, set = dig_keys.map{|key| [key, {}]}.append([k,v]).transpose.append([])
      keys.each_with_object(h) do |k, hsh|
        existing_val, i = h.dig(*set.append(k)), keys.index(k)
        #next unless !existing_val || concat_arr?(vals[i], existing_val)
        next unless !existing_val || existing_val.is_a?(Array)
        inject_merge(h, k, dig_val(vals[i], existing_val), set, (i-1))
      end
    end

    def infer_dig_keys_and_merge(h, k, v)
      keys = infer_dig_keys(h, k)
      return h.merge!({k=>v}) if keys.empty?
      v.each_with_object(h){|(k,v),h| nested_merge(h, k, v, keys)}
    end

    def infer_dig_keys(h, match_key, keys=[])
      return keys.clear if !h.is_a?(Hash)
      h.each_with_object(keys) do |(k,v), keys|
        keys.append(k)
        return keys if k == match_key
        infer_dig_keys(v, match_key, keys)
      end
    end

    def inject_merge(h, k, v, set, i)
      set[0] != k ? set[0..i].inject(h, :fetch)[k] = v : h[k] = v
    end

    def dig_val(v, existing_val)
      if concat_arr?(v,existing_val)
        (existing_val + v)
      elsif append_arr?(v,existing_val)
        existing_val.append(v)
      else
        v
      end
    end

    def concat_arr?(v,existing_val)
      existing_val && v.is_a?(Array) && existing_val.is_a?(Array)
    end

    def append_arr?(v,existing_val)
      existing_val && !v.is_a?(Array) && existing_val.is_a?(Array)
    end

  end
end

# def dig_val(v, existing_val)
#   concat_arr?(v,existing_val) ? (existing_val + v) : v
# end
# def param_merge(params:, dig_set:, keys:[])
#   dig_keys, dig_values = dig_set[0], dig_set[1]
#   dig_keys.each_with_index do |k, i|
#     if !params.dig(*keys.append(k))
#       if params.has_key?(dig_keys[0])
#         keys[0..i-1].inject(params, :fetch)[k] = dig_values[i]
#       else
#         params[k] = dig_values[i]
#       end
#     end
#   end
#   params
# end
#
# def dig_set(k:, v: nil, dig_keys: [])
#   return [[k],[v]] if k && dig_keys.one? && k == dig_keys[0] || k && dig_keys.none?
#   dig_keys.map{|key| [key, {}]}.append([k,v]).transpose
# end
