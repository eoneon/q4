require 'active_support/concern'

module Hashable
  extend ActiveSupport::Concern

  class_methods do

    def case_merge(h, k, v, *dig_keys)
      case
        when dig_keys.any?; nested_merge(h, k, v, dig_keys)
        when h.empty?; h.merge!({k=>v})
        when h.keys.include?(k) && h[k].is_a?(Array); h.merge!({k=>dig_val(v, h[k])}) # dig_val(v, h[k])
        when v.is_a?(Hash); infer_dig_keys_and_merge(h, k, v)
      end
    end

    #replace
    def nested_merge(h, k, v, dig_keys)
      keys, vals, set = dig_keys.map{|key| [key, {}]}.append([k,v]).transpose.append([])
      keys.each_with_object(h) do |k, hsh|
        existing_val, i = h.dig(*set.append(k)), keys.index(k)
        next if existing_val && !existing_val.is_a?(Array)
        inject_merge(h, k, dig_val(vals[i], existing_val), set, (i-1))
      end
    end

    def infer_dig_keys_and_merge(h, k, v)
      keys = infer_dig_keys(h, k)
      return h.merge!({k=>v}) if keys.empty?
      v.each_with_object(h){|(k,v),h| nested_merge(h, k, v, keys)}
    end

    #replace
    def infer_dig_keys(h, match_key, keys=[])
      return keys.clear if !h.is_a?(Hash)
      h.each_with_object(keys) do |(k,v), keys|
        keys.append(k)
        return keys if k == match_key
        infer_dig_keys(v, match_key, keys)
      end
    end
    
    #replace
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

    ############################################################################
    #replaces inject_merge #####################################################
    def nested_assign(h,v,*keys)
      keys[0..-2].inject(h){|h,k| h[k] = h[k] || {}}[keys[-1]] = v
      h
    end
    ###########################################################################
    ###########################################################################

    def infer_keys(h, m_key, m_val)
      if vals = dig_keys_with_end_val(h).detect{|vals| m_key == vals[-2] && m_val == vals[-1]}
        vals[0..-2]
      end
    end

    # Item.infer_keys(h:h, match_key: :StandardAuthentication, match_val:[:StandardCertificate])
    def dig_keys_with_end_val(h, keys=[], i=0, set=[])
      keys.clear if i==0
      h.each_with_object(set) do |(k,v), set|
        keys = keys[0...i].append(k)
        if v.is_a? Hash
          dig_keys_with_end_val(v, keys, i+1, set)
        else
          set.append(keys[0...i+1].append(v))
        end
      end
    end

    def map_args(set, *args)
      args = args.none? ? ('a'..'z').to_a.map(&:to_sym)[0...set[0].count] : args[0...set[0].count]
      set.map{|vals| [args,vals].transpose.to_h}
    end

  end
end

# v1
# def infer_keys(h, m_key, m_val, i=0, keys=[])
#   return @result if @result
#   keys.clear if i==0
#
#   h.each_with_object(keys) do |(k,v), keys|
#     return @result if @result
#     keys = keys[0...i].append(k)
#     if v.is_a? Hash
#       infer_keys(v, m_key, m_val, i+1, keys)
#     elsif k == m_key && v == m_val
#       return @result = keys
#     end
#   end
# end

# def infer_keys(h, match_key, keys=[])
#   return keys.clear if !h.is_a?(Hash)
#   h.each_with_object(keys) do |(k,v), keys|
#     keys.append(k)
#     return keys if k == match_key
#     infer_keys(v, match_key, keys)
#   end
# end

# def nested_keys_and_end_val(hsh, keys=nil, i=0)
#   keys = !keys ? ('a'..'z').to_a.map(&:to_sym) : keys
#   #hsh_loop(hsh: hsh).each_with_index{|k,i| {keys[i] => k}}
#   hsh_loop(hsh: hsh).each_with_object({}) do |k,h|
#     h.merge!({keys[i] => k})
#     i+=1
#   end
# end

############################################################################
# def product_assocs(store)
#   assoc_hsh = build_assoc_hsh(store)
#   origin, group, set = [:origin, :group, :set].map{|a_key| assoc_hsh[a_key]}
#   origin.each do ||
#   end
# end

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
