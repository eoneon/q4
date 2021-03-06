require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  included do
    before_destroy :remove_dependent_item_groups
  end

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

  def h_vals(h,*keys)
    keys.map{|k| h[k]}
  end

  def remove_dependent_item_groups
    ItemGroup.where(origin_id: self.id).or(ItemGroup.where(target_id: self.id)).destroy_all
  end

end

##############################################################################

# def h_args(h:, keys: nil, args: nil)
#   h_vals = h_vals(h: h, keys: keys)
#   args ? h_vals + args : h_vals
# end
#
# def h_vals(h:, keys: nil)
#   keys ? keys.map{|k| h[k]} : h.values
# end
