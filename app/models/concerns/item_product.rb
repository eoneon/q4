require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # a = Item.find(97).input_rows
  def input_rows
    return {} if !product
    pg_hsh = product.input_set(product.g_hsh, input_params).group_by{|h| h[:k]}
    form_group = Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
    assign_row(pg_hsh, form_group)
  end

  def assign_row(pg_hsh, form_group)
    form_group.each_with_object([]) do |form_row, rows|
      row = form_row.select{|col| pg_hsh.has_key?(col)}
      rows.append(row.map!{|col| pg_hsh[col]}.flatten!) if row.any?
    end
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
