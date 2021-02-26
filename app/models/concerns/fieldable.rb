require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  # p.prg_hsh(p)
  def prg_hsh(p, i=Item.find(97))
    input_groups = p.grouped_inputs(p.g_hsh(p))
    @p_params = i.p_params
    param_loop(input_groups)
  end

  ##############################################################################

  def param_loop(input_groups, inputs={})
    param_args(input_groups).each do |args|
      input = assoc_selected(args[:k], args[:t], args[:input_name], args[:input])
      param_merge(params: inputs, dig_set: dig_set(k: args[:input_name], v: input, dig_keys: [args[:k], args[:t]]))
      nested_params(input['selected'], inputs) if input['selected'] && !input['selected'].is_a?(String)
    end
    inputs
  end

  def param_args(input_groups, a=[])
    input_groups.each do |k, field_group|
      if k == 'FieldSet'
        param_args(field_group, a)
      else
        fg_params(k, field_group, a)
      end
    end
    a
  end

  def fg_params(k, field_group, a)
    field_group.each do |t, field_inputs|
      input_params(k, t, field_inputs, a)
    end
    a
  end

  def input_params(k, t, field_inputs, a)
    field_inputs.each do |input_name, input|
      a.append({k: k, t: t, input_name: input_name, input: input})
    end
    a
  end

  ##############################################################################

  def nested_params(f, hsh)
    if f.type == 'FieldSet'
      param_loop(f.grouped_inputs(f.g_hsh(f)), hsh)
    end
  end

  ##############################################################################

  def assoc_selected(k, t, input_name, input)
    if f = detect_assoc(t, input_name, input)
      input['selected'] = f
    end
    input
  end

  def detect_assoc(t, input_name, input)
    if input_attrs.exclude?(t)
      input['obj'].fieldables.detect{|f| @p_params['fields'].include?(f)}
    else
      @p_params.dig('tags', input_name)
    end
  end

  ##############################################################################

  def grouped_inputs(g_hsh, h={})
    g_hsh.each do |k, t_hsh|
      t_hsh.each do |t, f_hsh|
        expand_field_set(k, t, f_hsh, h)
      end
    end
    h
  end

  def expand_field_set(k, t, f_hsh, h)
    if t != 'FieldSet'
      h.merge!({k=> grouped_input_hsh(t, f_hsh)})
    else
      f_hsh.values.map{|fs| handle_fs(t, fs.fieldables, h)} #f_hsh.values.map{|fs| grouped_inputs(grouped_hsh(enum: fs.fieldables), h)}
    end
  end

  def handle_fs(t, fs_fields, h)
    if fs_fields.pluck(:kind).uniq.one?
      h.merge!({t=> grouped_inputs(grouped_hsh(enum: fs_fields))})
    else
      grouped_inputs(grouped_hsh(enum: fs_fields), h)
    end
  end

  def grouped_input_hsh(t, f_hsh, h={})
    f_hsh.each do |f_name, f|
      h.merge!({f_name=>{'obj'=>f, 'selected'=>nil}})
    end
    {t => h}
  end

  def g_hsh(context)
    context.grouped_hsh(enum: context.fieldables, attrs: context.f_attrs)
  end

  ##############################################################################

  def p_params
    tags = self.tags ? self.tags : {}
    {'fields'=> fieldables, 'tags'=> tags}
  end

  def f_attrs
    [:kind, :type, :field_name]
  end

  def input_attrs
    ['NumberField', 'TextField', 'TextAreaField']
  end

  def fieldables
    item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
  end

  ##############################################################################

  def grouped_hsh(enum:, i: 0, attrs: f_attrs)
    enum, i = enum.group_by(&attrs[i]), i+1 if enum.is_a? Array
    enum.transform_values!{|val_set| val_set.group_by(&attrs[i])} if enum.is_a? Hash
    enum.values.map{|hsh| grouped_hsh(enum: hsh, i: i+1, attrs: attrs)}  if i < attrs.count - 1
    enum.values.map{|hsh| hsh.transform_values!{|v| v[0]}} if i == attrs.count - 1
    enum
  end

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

# def field_assocs(field_type)
#   field_type.classify.constantize.assoc_names.map{|assoc| assoc.singularize.classify}
# end
