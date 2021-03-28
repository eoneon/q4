require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  def field_args(field_groups, set=[])
    a = field_groups.each_with_object(set) do |(k, field_groups), a|
      field_groups.each do |t, fields|
        fields.each do |f_name, f_val|
          unpack_or_assign(k, t, f_name, f_val, a)
        end
      end
    end
  end

  def unpack_or_assign(k, t, f_name, f_val, a)
    if unpack?(t)
      field_args(f_val.g_hsh, a)
    else
      a.append({k: k.underscore, t: t.underscore, f_name: f_name.underscore, f_val: f_val})
    end
  end

  def unpack?(t)
    #field_set?(t) && self.class.name == 'Product'
    puts "t.underscore: #{t.underscore} & #{self.class.name}"
    t.underscore == 'field_set' && self.class.name == 'Product'
  end

  ##############################################################################
  #boolean test methods ########################################################
  # def field_set?(t)
  #   t.underscore == 'field_set'
  # end
  #
  # def select_field?(t)
  #   t.underscore == 'select_field'
  # end
  #
  # def select_menu?(t)
  #   t.underscore == 'select_menu'
  # end
  #
  # def tag_attr?(t)
  #   tag_attrs.include?(t)
  # end
  #
  # def tag_attrs
  #   %w[number_field text_field text_area_field]
  # end
  ##############################################################################
  # original methods
  ##############################################################################

  def param_args(field_groups:, a:[], unpack: nil)
    field_groups.each do |k, field_group|
      if k == 'FieldSet'
        param_args(field_groups: field_group, a: a, unpack: unpack)
      else
        fg_params(k, field_group, a, unpack)
      end
    end
    a
  end

  def fg_params(k, field_group, a, unpack)
    field_group.each do |t, fields|
      if t == 'FieldSet' && unpack          #repeat_param_arg_loop?(t,unpack)
        fields.each{|f_name, f| param_args(field_groups: f.g_hsh, a: a, unpack: unpack)}
      else
        fields.each{|f_name, f_obj| a.append(input_args(k, t, f_name, f_obj))}
      end
    end
    a
  end

  def input_args(k, t, f_name, f_obj)
    {k: k.underscore, t: t.underscore, t_type: f_scope(t).try(:underscore), f_name: f_name.underscore, f_obj: f_obj}
  end

  def f_scope(field_type)
    assoc = input_attr?(field_type)
    assoc ? assoc : field_assocs(field_type).first
  end

  def field_assocs(field_type)
    field_type.classify.constantize.assoc_names.map{|assoc| assoc.singularize.classify}
  end

  ##############################################################################



  ##############################################################################

  def input_attr?(field_type)
    'tags' if input_attrs.include?(field_type) || field_type == 'tags'
  end

  def input_attrs
    ['NumberField', 'TextField', 'TextAreaField']
  end
  ##############################################################################

  def fieldables
    item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
  end

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

end
