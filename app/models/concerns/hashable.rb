require 'active_support/concern'

module Hashable
  extend ActiveSupport::Concern

  class_methods do

    def case_merge(h, v, *dig_keys)
      if val = valid_merge?(v, h.dig(*dig_keys))
        v.is_a?(Hash) ? infer_keys_and_merge(h, dig_keys[-1], v) : nested_assign(h, val, dig_keys)
      else
        h
      end
    end

    def valid_merge?(v, v2)
      if v2.nil?
        v
      elsif v2.is_a?(Array)
        v.is_a?(Array) ? (v2 + v) : v2.append(v)
      end
    end

    def nested_assign(h,v,keys)
      keys[0..-2].inject(h){|h,k| h[k] = h[k] || {}}[keys[-1]] = v
      h
    end

    def infer_keys(h, m_key, m_val)
      if vals = dig_keys_with_end_val(h:h).detect{|vals| m_key == vals[-2] && m_val == vals[-1]}
        vals[0..-2]
      end
    end

    def infer_keys_and_merge(h, m_key, m_val)
      v.each_with_object(h){|(k,v),h| nested_assign(h, v, infer_keys(h, m_key, m_val))}
    end

    #loop method for nested hshs ###############################################

    def dig_keys_with_end_val(h:, keys:[], i:0, set:[])
      keys.clear if i==0
      h.each_with_object(set) do |(k,v), set|
        keys = keys[0...i].append(k)
        if v.is_a? Hash
          dig_keys_with_end_val(h:v, keys:keys, i:i+1, set:set)
        else
          set.append(keys[0...i+1].append(v))
        end
      end
    end

    def map_args(set, *args)
      args = args.none? ? ('a'..'z').to_a.map(&:to_sym)[0...set[0].count] : args[0...set[0].count]
      set.map{|vals| [args,vals].transpose.to_h}
    end

    #array methods #############################################################

    def include_any?(arr_x, arr_y)
      arr_x.any? {|x| arr_y.include?(x)}
    end

    def include_all?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.include?(x)}
    end

    def exclude_all?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.exclude?(x)}
    end

    def include_none?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.exclude?(x)}
    end

    def include_pat?(str, pat)
      str.index(/#{pat}/)
    end

  end
end

############################################################################
############################################################################

# def inject_merge(h, k, v, set, i)
#   set[0] != k ? set[0..i].inject(h, :fetch)[k] = v : h[k] = v
# end

#replaces: nested_merge
# def concat_merge(h, v, *dig_keys)
#   puts "#{dig_keys}"
#   existing_val = h.dig(dig_keys)
#   existing_val.present? && !existing_val.is_a?(Array) ? h : nested_assign(h, dig_val(v, existing_val), dig_keys)
# end

# def nested_keys_and_end_val(hsh, keys=nil, i=0)
#   keys = !keys ? ('a'..'z').to_a.map(&:to_sym) : keys
#   #hsh_loop(hsh: hsh).each_with_index{|k,i| {keys[i] => k}}
#   hsh_loop(hsh: hsh).each_with_object({}) do |k,h|
#     h.merge!({keys[i] => k})
#     i+=1
#   end
# end
