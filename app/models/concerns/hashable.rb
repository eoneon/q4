require 'active_support/concern'

module Hashable
  extend ActiveSupport::Concern

  # parameter methods  #########################################################
  def order_hsh(keys, hsh)
    hsh.blank? ? {} : keys.each_with_object({}) {|k,h| h[k]=hsh.dig(k)}
  end

  def order_valid_hsh(keys, hsh)
    order_hsh(keys, hsh).reject{|k,v| v.blank?}
  end

  def default_hsh(*keys)
    keys.each_with_object({}) {|k,h| h[k]=""}
  end

  def trans_args(arg_list)
    arg_list.each_with_object({a:[],b:[]}) {|i,args| arg_list.index(i).even? ? args[:a].append(i) : args[:b].append(i)}.values.transpose
  end

  # update sorted tag_keys  ####################################################
  def remove_keys(keys, *reject_set)
    reject_set.each_with_object(keys){|k, keys| remove_key(keys, k)}
  end

  def remove_key(keys, k)
    keys.slice!(keys.index(k))
  end

  def reorder_keys(keys:, k:, ref: nil, i: 0)
    remove_key(keys, k)
    keys.insert(reorder_idx(i, ref, keys), k)
  end

  def reorder_idx(i, ref, keys)
    ref.nil? ? i : keys.index(ref)+i
  end

  def rev_detect(set, keys)
    set.reverse.detect{|k| keys.include?(k)}
  end

  def vals_exist?(h, keys, check: :all?)
    keys.public_send(check){|k| h[k].present?} if keys
  end

  # hsh filter methods  ########################################################
  def filtered_hsh(h:, keys:[], dig_set:[])
    keys.each_with_object({}) do |k,hsh|
      if v = h.dig(*dig_set.dup.prepend(k))
        hsh[k] = v
      end
    end
  end

  def extract_and_flatten(k, nested_hsh, hsh)
    nested_hsh.count>1 ? hsh.merge!(nested_hsh) : hsh[k] = nested_hsh.values[0]
  end

  def flatten_hsh(h)
    h.transform_values!{|v_hsh| v_hsh.values[0]}
  end

  # val_slice  ################################################################# # Hash: if v = h.dig(k); returns v and h.delete(k); else nil # Array: if a.index(k); returns i and deletes i from a; else nil
  def slice_and_delete(enum,k)
    if enum.is_a?(Hash)
      hsh_slice_and_delete(enum,k)
    else
      arr_slice_and_delete(enum,k)
    end
  end

  def slice_valid_subhsh!(h,*keys)
    new_hsh = h.select{|k,v| keys.include?(k) && v.present?}
    if new_hsh.any?
      new_hsh.keys.map{|k| h.delete(k)}
      new_hsh
    end
  end

  def hsh_slice_and_delete(h,k)
    if v = h.dig(k)
      h.delete(k)
      v
    end
  end

  def arr_slice_and_delete(a,i)
    if idx = a.index(i)
      a.slice!(idx)
    end
  end

  # vals_slice  ################################################################# Hash: if v = h.dig(k); returns v and h.delete(k); else nil # Array: if a.index(k); returns i and deletes i from a; else nil
  def slice_vals_and_delete(enum,*keys)
    if enum.is_a?(Hash)
      slice_hsh_vals_and_delete(enum,keys)
    else
      slice_arr_vals_and_delete(enum,keys)
    end
  end

  def slice_hsh_vals_and_delete(h,*keys)
    keys.flatten.each_with_object({}) do |k, hsh|
      if v = hsh_slice_and_delete(h,k)
        hsh[k]=v
      end
    end
  end

  def slice_arr_vals_and_delete(a,*items)
    items.flatten.each_with_object([]) do |i, set|
      set.append(i) if arr_slice_and_delete(a,i)
    end
  end

  def slice_and_transfer(h:,h2:,keys:,k:nil)
    if hsh = slice_vals_and_delete(h,keys)
      k ? h2[k] = hsh : h2[keys[0]] = hsh[keys[0]]
    end
  end

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

    #replaces param_set ########################################################
    def build_params(params, *args)
      hsh = dig_keys_with_end_val(h: params)
      map_args(hsh,*args)
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

    #hash filter methods ####################################################### might want to check this one out
    def update_default_hsh_from_old_hsh(required_keys, default_hsh, store_hsh)
      return default_hsh if required_keys.empty?
      store_hsh.each_with_object(default_hsh) do |(k,v), default_hsh|
        if v.is_a? Hash
    	    update_default_hsh_from_old_hsh(required_keys, default_hsh, v)
        elsif required_keys.include?(k)
          required_keys.delete(k)
          store_hsh.delete(k)
    	    default_hsh[k] = v if !v.blank?
        end
      end
    end

    def filter_hsh(h, key_set, reject_set=[])
      if h = filter_hsh_by_keys(h, key_set)
        h = filter_hsh_vals(h, reject_set)
        h if hsh_keys_exist?(h, key_set)
      end
    end

    def filter_hsh_by_keys(h, valid_keys)
      h.select{|k,v| key_set.include?(k)} if hsh_keys_exist?(h, key_set)
    end

    def hsh_keys_exist?(h, key_set) # companion vals exist?
      h && key_set.all?{|k| h.keys.include?(k)}
    end

    def filter_hsh_vals(h, invalid_vals)
      h.select{|k,v| invalid_vals.exclude?(v)} if h
    end

    def defualt_hsh(*keys)
      keys.flatten.each_with_object({}) {|k,h| h[k]=""}
    end
    #array methods ############################################################# might want to check this one out

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

    def clean_hsh(hsh)
    	hsh.reject! do |k,v|
    		v.blank? || v.class==Hash && v.all?{|key, val| val.blank?}
    		if v.class==Hash && v.any?{|key, val| val.present?}
    			clean_hsh(v)
    		end
    	end
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
