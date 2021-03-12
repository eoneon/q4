require 'active_support/concern'

module Fieldable
  extend ActiveSupport::Concern

  # p.prg_hsh(p)
  # fs.prg_hsh(fs)
  def prg_hsh(p, i=Item.find(97))
    @i_params = i.i_params(i, i.tags)
    input_loop(p.g_hsh(p))
  end

  ############################################################################## p.param_args(field_groups: p.g_hsh(p), unpack: true) - i.param_args(field_groups: i.g_hsh(i))

  def input_loop(field_groups, inputs={})
    param_args(field_groups: field_groups, unpack: true).each do |h|
      #k, t, f_name, f_obj = [h[:k], f_scope(h[:t]), h[:f_name]].map(&:underscore).append(h[:f_obj])
      k, t_type, f_name, f_obj = [:k, :t_type, :f_name, :f_obj].map{|k| h[k]}
      selected = @i_params.dig(k,t_type,f_name) # @i_params.dig(k,t_type,f_name)
      param_merge(params: inputs, dig_set: dig_set(k: f_name, v: f_hsh(f_obj, selected), dig_keys: [k, t_type])) # [k, t_type]
      input_loop(f_obj.g_hsh(selected), inputs) if selected && t_type != 'tags' && selected.type == 'FieldSet'   # t_type != 'tags'/input_attr?(t) / repeat_input_loop?(selected,t)
    end
    inputs
  end

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
        fields.each{|f_name, f| param_args(field_groups: f.g_hsh(f), a: a, unpack: unpack)}
      else
        #fields.each{|f_name, f_obj| a.append({k: k, t: t, f_name: f_name, f_obj: f_obj})}
        fields.each{|f_name, f_obj| a.append(input_args(k, t, f_name, f_obj))}
      end
    end
    a
  end

  # def input_args(k, t, f_name, f_obj)
  #   {k: k.underscore, t: t.underscore, t_type:, f_scope(f_name).underscore, f_name:f_name.underscore, f_obj: f_obj}
  # end

  def input_args(k, t, f_name, f_obj)
    {k: k.underscore, t: t.underscore, t_type: f_scope(t).try(:underscore), f_name: f_name.underscore, f_obj: f_obj}
  end
  #input_hsh ###################################################################

  def f_hsh(f_obj, selected)
    {render_as: f_obj.type.underscore, method: f_obj.field_name.underscore, f_obj: f_obj, selected: format_selected(selected)}
  end

  ##############################################################################

  def i_params(i, tags, hsh={})
    i.param_args(field_groups: i.g_hsh(i)).each do |h|
      param_merge(params: hsh, dig_set: dig_set(i_dig_hsh(h, tags)))
      #fs_params(i.g_hsh(h[:f_obj]), tags, hsh) if h[:t] == 'FieldSet'  #t -> 'field_set'
      fs_params(i.g_hsh(h[:f_obj]), tags, hsh) if h[:t] == 'field_set'
    end
    hsh
  end

  def fs_params(field_groups, tags, hsh)
    param_args(field_groups: field_groups).each do |h|
      #k, t, f_name = [h[:k], f_scope(h[:t]), h[:f_name]].map(&:underscore)
      k, t_type, f_name, f_obj = h[:k], h[:t_type], h[:f_name], h[:f_obj]
      if f_val = tags.dig(f_name)
        #param_merge(params: hsh, dig_set: dig_set(k: f_name, v: detect_assoc(t, f_val, h[:f_obj]), dig_keys: [k, t])) #[k, t_type]
        param_merge(params: hsh, dig_set: dig_set(k: f_name, v: detect_assoc(t_type, f_val, f_obj), dig_keys: [k, t_type])) #[k, t_type]
      end
    end
    hsh
  end

  def i_dig_hsh(h, tags)
    #k, t, f_name, f_val = [:k, :t, :f_name].map{|k| h[k].underscore}.append(h[:f_obj])
    k, t, f_name, f_val = [:k, :t, :f_name, :f_obj].map{|k| h[k]}
    if input_attr?(t)
      {k: f_name, v: tags.dig(f_name), dig_keys: [k, 'tags']}
    else
      {k: tags.key(f_val.id.to_s), v: f_val, dig_keys: [k, t]}
    end
  end

  # methods for refactored i_dig_hsh: 1st: refactor param_args #################
  def infer_param_key(t, f_val, f_name, tags)
    input_attr?(t) ? f_name : tags.key(f_val.id.to_s)
  end

  def infer_param_value(t, f_val, f_name, tags)
    input_attr?(t) ? tags.dig(f_name) : f_val
  end

  def infer_type(t)
    input_attr?(t) ? 'tags' : t
  end
  ##############################################################################

  def detect_assoc(t, f_val, f_obj)
    return f_val if t == 'tags'
    f_obj.fieldables.detect{|f| f.id == f_val.to_i && f.field_type == t.classify}
  end

  def format_selected(selected)
    return selected if selected.nil? || selected.is_a?(String)
    selected.id
  end

  ##############################################################################

  # def f_scope(field_type)
  #   if assoc = input_attr?(field_type)
  #     assoc
  #   else
  #     field_assocs(field_type).first
  #   end
  # end

  def f_scope(field_type)
    assoc = input_attr?(field_type)
    assoc ? assoc : field_assocs(field_type).first
  end

  def input_attr?(field_type)
    'tags' if input_attrs.include?(field_type)
  end

  def field_assocs(field_type)
    field_type.classify.constantize.assoc_names.map{|assoc| assoc.singularize.classify}
  end

  ##############################################################################

  # def p_params
  #   tags = self.tags ? self.tags : {}
  #   {'fields'=> fieldables, 'tags'=> tags}
  # end

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

  def g_hsh(context)
    context.grouped_hsh(enum: context.fieldables.select{|f| f.type != "RadioButton"}, attrs: context.f_attrs)
  end

  def grouped_hsh(enum:, i: 0, attrs: f_attrs)
    enum, i = enum.group_by(&attrs[i]), i+1 if enum.is_a? Array
    enum.transform_values!{|val_set| val_set.group_by(&attrs[i])} if enum.is_a? Hash
    enum.values.map{|hsh| grouped_hsh(enum: hsh, i: i+1, attrs: attrs)}  if i < attrs.count - 1
    enum.values.map{|hsh| hsh.transform_values!{|v| v[0]}} if i == attrs.count - 1
    enum
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

##############################################################################
##############################################################################
  # def nested_params(f, hsh)
  #   if f.type == 'FieldSet'
  #     input_loop(f.grouped_inputs(f.g_hsh(f)), hsh)
  #   end
  # end

  # def build_input(f_type, f_name, f_obj, selected)
  #   f_hsh(f_type, f_name, f_obj, selected)
  # end

  # def detect_assoc(f_type, f_name, f_obj)
  #   if input_attrs.exclude?(f_type)
  #     f_obj.fieldables.detect{|f| @p_params['fields'].include?(f)}
  #   else
  #     @p_params.dig('tags', f_name)
  #   end
  # end

  # def unpack_field_sets(field_groups, hsh={})
  #   param_args(field_groups).each do |h|
  #     param_merge(params: hsh, dig_set: dig_set(k: h[:f_name], v: h[:f_obj], dig_keys: [h[:k], h[:t]]))
  #     unpack_field_sets(grouped_hsh(enum: h[:f_obj].fieldables), hsh) if h[:t] == 'FieldSet' #g_hsh
  #     #unpack_field_sets( g_hsh( h[:f_obj] ), hsh) if h[:t] == 'FieldSet'
  #   end
  #   hsh
  # end
  #
  # def grouped_inputs(g_hsh, h={})
  #   g_hsh.each do |k, t_hsh|
  #     t_hsh.each do |t, f_hsh|
  #       expand_field_set(k, t, f_hsh, h)
  #     end
  #   end
  #   h
  # end
  #
  # def expand_field_set(k, t, f_hsh, h)
  #   if t != 'FieldSet'
  #     h.merge!({k=> {t => f_hsh}}) #h.merge!({k=> grouped_input_hsh(t, f_hsh)})
  #   else
  #     f_hsh.values.map{|fs| handle_fs(t, fs.fieldables, h)} #f_hsh.values.map{|fs| grouped_inputs(grouped_hsh(enum: fs.fieldables), h)}
  #   end
  # end
  #
  # def handle_fs(t, fs_fields, h)
  #   if fs_fields.pluck(:kind).uniq.one?
  #     #h.merge!({t=> grouped_inputs(grouped_hsh(enum: fs_fields))})
  #     h.merge!(grouped_inputs(grouped_hsh(enum: fs_fields)))
  #   else
  #     grouped_inputs(grouped_hsh(enum: fs_fields), h)
  #   end
  # end

  # i.i_params(i, i.tags)
  # def i_params(i, tags, h={})
  #   i.param_args(i.g_hsh(i)).each do |args|
  #     k, t, f_name, f = [:k, :t, :f_name].map{|k| args[k].underscore}.append(args[:f_obj])
  #     param_merge(params: h, dig_set: dig_set(dig_hsh(k, t, f_name, f, tags, input_attr?(args[:t])))) #dig_hsh = dig_hsh(k, t, f_name, f, tags, i.input_attrs.include?(args[:t]))
  #     #fs_params(f.grouped_inputs(f.g_hsh(f)), tags, h) if args[:t] == 'FieldSet'
  #     fs_params(f.unpack_field_sets(f.g_hsh(f)), tags, h) if args[:t] == 'FieldSet'
  #   end
  #   h
  # end
  #
  # #k.underscore, t.underscore, f_name.underscore, f_val, f.input_attrs.include?(t)
  # def dig_hsh(k, t, f_name, f_val, tags, tag_context)
  #   {k: f_name, v: tags.dig(f_name), dig_keys: [k, 'tags']} if tag_context
  #   {k: tags.key(f_val.id.to_s), v: f_val, dig_keys: [k, t]} if !tag_context
  # end
  #
  # def fs_params(field_groups, tags, h)
  #   param_args(field_groups).each do |args|
  #     k, t, f_name = [args[:k], f_scope(args[:t]), args[:f_name]].map(&:underscore)
  #     if f_val = tags.dig(f_name)
  #       param_merge(params: h, dig_set: dig_set(k: f_name, v: detect_assoc(t, f_val, args[:f_obj]), dig_keys: [k, t])) #f_val = detect_assoc(t, f_val, args[:f_obj])
  #     end
  #   end
  #   h
  # end

  # def fg_params(k, field_group, a)
  #   field_group.each do |t, fields|
  #     input_params(k, t, fields, a)
  #   end
  #   a
  # end

  # def fg_params(k, field_group, a)
  #   field_group.each do |t, fields|
  #     if t == 'FieldSet'
  #       fields.each{|f_name, f| param_args(f.g_hsh(f),a)}
  #     else
  #       fields.each{|f_name, f_obj| a.append({k: k, t: t, f_name: f_name, f_obj: f_obj})}
  #     end
  #   end
  #   a
  # end


  # def input_params(k, t, fields, a)
  #   fields.each do |f_name, f_obj|
  #     a.append({k: k, t: t, f_name: f_name, f_obj: f_obj})
  #   end
  #   a
  # end

  # def grouped_input_hsh(t, f_hsh, a=[])
  #   f_hsh.each do |f_name, f|
  #     a.append(f)
  #   end
  #   {t => a} # {t.underscore => h}
  # end

  # def grouped_input_hsh(t, f_hsh, h={})
  #   f_hsh.each do |f_name, f|
  #     h.merge!({f_name=>f})
  #   end
  #   {t => h} # {t.underscore => h}
  # end
