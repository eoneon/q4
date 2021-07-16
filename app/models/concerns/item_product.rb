require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # d_hsh = Item.find(97).input_group['d_hsh']

  def input_group(h={'rows'=>{}})
    !product ? h : rows_and_names(product, product.fieldables, h)
  end

  def rows_and_names(p, p_fields, h)
    g_hsh = grouped_hsh(enum: p_fields.select{|f| f.type != "RadioButton"})
    rows = assign_row(product.input_set(g_hsh, input_params).group_by{|h| h[:k]})
    h.merge!({'rows'=> rows, 'd_hsh'=> format_d_hsh(d_hsh(rows, item_names(p_fields)))})
  end

  def item_names(p_fields)
    p_fields.each_with_object({}) do |f,h|
      h[f.kind] = {f.field_name => f.tags['item_name']} if f.tags && f.tags.has_key?('item_name')
    end
  end

  def assign_row(pg_hsh)
    kinds.each_with_object([]) do |form_row, rows|
      row = form_row.select{|col| pg_hsh.has_key?(col)}
      rows.append(row.map!{|col| pg_hsh[col]}.flatten!) if row.any?
    end
  end

  ##############################################################################
  def d_hsh(rows,name_hsh)
    rows.flatten.select{|h| h[:value].present? && h[:t] != 'select_menu'}.each_with_object(name_hsh) do |f_hsh,name_hsh|
      Item.case_merge(name_hsh, [f_hsh[:value]], f_hsh[:k], f_hsh[:f_name])
    end
  end

  def format_d_hsh(d_hsh)
    d_hsh.each_with_object({}) do |(k,v_hsh),h|
      v_hsh.transform_values!{|v| v[0]}
      h[k] = v_hsh.one? ? v_hsh.values[0] : v_hsh
    end
  end

  def build_description(d_hsh)
    kinds.each_with_object({}) do |k,h|
      if v = d_hsh[k.underscore]
        h[k.underscore] = to_class(k).description(v)
      end
    end
  end
  ##############################################################################

  def kinds
    Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
  end

  def input_params
    self.tags.each_with_object({}) do |(tag_key, tag_val), h|
      if tag_assoc_keys = tag_assoc_keys(tag_key)
        k, t, f_name = tag_assoc_keys
        Item.case_merge(h, input_val(t, tag_val), k, t, f_name)
      end
    end
  end

  def input_val(t, tag_val)
    tag_attr?(t) ? tag_val : detect_input_val(t, tag_val.to_i)
  end

  def detect_input_val(t, id)
    fieldables.detect{|f| attr_match?(f, t, id)}
  end

  def attr_match?(f, t, id)
    f.id == id && f.type.underscore == t
  end

  def tag_assoc_keys(tag_key)
    tag_key.split('::') if tag_key.index('::')
  end

end

# def input_rows
#   return {} if !product
#   pg_hsh = product.input_set(product.g_hsh, input_params).group_by{|h| h[:k]}
#   form_group = Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
#   assign_row(pg_hsh, kinds)
# end

# def input_rows
#   return {} if !product
#
#   p_fields = product.fieldables
#   item_names_hsh = item_names(p_fields)
#   g_hsh = grouped_hsh(enum: p_fields.select{|f| f.type != "RadioButton"})
#
#   pg_hsh = product.input_set(g_hsh, input_params).group_by{|h| h[:k]}
#   assign_row(pg_hsh)
# end
