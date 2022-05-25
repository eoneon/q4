require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  included do
    before_destroy :remove_dependent_item_groups
  end

  def f_args(f_groups, set=[])
    Product.dig_keys_with_end_val(h: f_groups).each_with_object(set) do |args, set|
      unpack?(args[1]) ? f_args(args[-1].g_hsh, set) : set.append(input_hsh(*args[0..-2].map!(&:underscore).append(args[-1])))
    end
  end

  def input_hsh(k, t, f_name, f_val)
    [[:k,:t,:t_type,:f_name,:f_val], [k, t, f_assoc(t), f_name, f_val]].transpose.to_h
  end

  def input_vals(k, t, f_name, f_val)
    [k, t, f_assoc(t), f_name, f_val]
  end

  def unpack?(t)
    field_set?(t) && product_class?
  end

  def fieldables
  	FieldItem.where(id: item_groups.where(base_type: 'FieldItem').order(:sort).pluck(:target_id)).to_a
  end

  def grouped_fields
    grouped_hsh(enum: unpacked_fields)
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
    grouped_hsh(enum: fieldables)
  end

  def f_attrs
    [:kind, :type, :field_name]
  end

  ##############################################################################

  def h_vals(h,*keys)
    keys.map{|k| h[k]}
  end

  def remove_dependent_item_groups
    ItemGroup.where(origin_id: self.id).or(ItemGroup.where(target_id: self.id)).destroy_all
  end

end

# def fieldables
#   item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
# end

# def grouped_item_hsh
# 	grouped_hsh(enum: unpacked_fields, attrs: [:kind, :type])
# end
# def product_fields
#   grouped_hsh(enum: nested_fieldables)
# end
