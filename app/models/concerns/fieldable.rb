require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  def field_args(field_groups, set=[])
    a = field_groups.each_with_object(set) do |(k, field_groups), a|
      field_groups.each do |t, fields|
        fields.each do |f_name, f_val|
          unpack_or_assign(k.underscore, t.underscore, f_name.underscore, f_val, a)
        end
      end
    end
  end

  def unpack_or_assign(k, t, f_name, f_val, a)
    if unpack?(t)
      field_args(f_val.g_hsh, a)
    else
      a.append({k: k, t: t, t_type: f_assoc(t), f_name: f_name, f_val: f_val})
    end
  end

  def unpack?(t)
    field_set?(t) && product_class?
  end

  def f_assoc(t)
    tag_attr?(t) ? t : {'select_field' => 'option', 'select_menu'=> 'field_set'}[t]
  end

  def fieldables
    item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
  end

  # def param_hsh(params, h={})
  #   params.each do |k, field_groups|
  #     field_groups.each do |t, fields|
  #       fields.each do |f_name, f_val|
  #         param_merge(params: h, dig_set: dig_set(k: f_name, v: f_val, dig_keys: []), keys:[k,t])
  #       end
  #     end
  #   end
  #   h
  # end

  ##############################################################################

  def grouped_hsh(enum:, i: 0, attrs: f_attrs)
    return enum if enum.empty?
    enum, i = enum.group_by(&attrs[i]), i+1 if enum.is_a? Array
    enum.transform_values!{|val_set| val_set.group_by(&attrs[i])} if enum.is_a? Hash
    enum.values.map{|hsh| grouped_hsh(enum: hsh, i: i+1, attrs: attrs)}  if i < attrs.count - 1
    enum.values.map{|hsh| hsh.transform_values!{|v| v[0]}} if i == attrs.count - 1
    enum
  end

  def g_hsh
    grouped_hsh(enum: fieldables.select{|f| f.type != "RadioButton"}, attrs: f_attrs)
  end

  def f_attrs
    [:kind, :type, :field_name]
  end

  ##############################################################################

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

  def h_vals(h,*keys)
    keys.map{|k| h[k]}
  end

end



##############################################################################
#
# def f_scope(field_type)
#   assoc = input_attr?(field_type)
#   assoc ? assoc : field_assocs(field_type).first
# end
#
# def field_assocs(field_type)
#   field_type.classify.constantize.assoc_names.map{|assoc| assoc.singularize.classify}
# end
