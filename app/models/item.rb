class Item < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :standard_products, through: :item_groups, source: :target, source_type: "StandardProduct"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  def field_targets
    scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many)
  end

  def product
    if product = targets.detect{|target| target.class.method_defined?(:type) && target.base_type == 'Product'}
      product
    end
  end

  def artist
    artists.first if artists.any?
  end

  # Item.find(5).field_targets ## h = Item.find(5).product_group['inputs'] ## h['inputs'] ## h['inputs']['field_sets']
  # product_group ############################################################## Item.find(3).product_group
  def product_group
    params, inputs = {}, {'options'=>[], 'field_sets'=>{}}
    return {'params'=>params, 'inputs'=>inputs} if !product
    p_fields, i_fields, opt_scope = product.field_targets, field_targets, %w[embellished category medium material]
    p_fields.each do |f|
      if f.type == 'SelectField'
        select_field_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'FieldSet'
        field_set_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'SelectMenu'
        select_menu_group(f, i_fields, params, inputs, opt_scope)
      end
    end
    {'params'=>params, 'inputs'=>inputs, 'description' => description_hsh(params['options'], params['field_sets'])}
    #{'params'=>params, 'inputs'=>inputs, 'description' => description_hsh(params)}
  end

  # field-type specific methods ################################################
  def select_field_group(sf, i_fields, params, inputs, opt_scope)
    opt = detect_obj(i_fields, sf.kind, 'Option')
    scope_keys = scope_keys(sf, 'Option', opt_scope)
    scope_set = scope_set(scope_keys, [sf.kind+'_id', opt])
    params_merge(params, scope_set)
    form_inputs(inputs, scope_keys[0..1], sf.kind, select_hsh(sf,opt))
  end

  def field_set_group(fs, i_fields, params, inputs, opt_scope)
    fs.targets.each do |f|
      if f.type == 'SelectField'
        select_field_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'SelectMenu'
        select_menu_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type != 'FieldSet'
        tags_group(f, params, inputs)
      end
    end
  end

  def select_menu_group(sm, i_fields, params, inputs, opt_scope)
    ff = detect_obj(i_fields, sm.kind, 'FieldSet', 'SelectField')
    scope_set = scope_set(['field_sets', sm.kind], [sm.kind+'_id', ff])

    params_merge(params, scope_set)
    form_inputs(inputs, ['field_sets', sm.kind], sm.kind, select_hsh(sm,ff))

    if ff && ff.type == 'FieldSet'
      field_set_group(ff, i_fields, params, inputs, opt_scope)
    elsif ff && ff.type == 'SelectField'
      select_field_group(ff, i_fields, params, inputs, opt_scope)
    end
  end

  def tags_group(f, params, inputs)
    k = f.field_name.split(" ").join("_")
    v = tags.present? && tags.has_key?(k) ? tags[k] : nil
    scope_keys = scope_keys(f, nil, nil)
    scope_set = scope_set(scope_keys, [k, v])

    params_merge(params, scope_set)
    form_inputs(inputs, scope_keys[0..1], scope_keys[1], store_hsh(f,k,v))
  end

  # product_group specific methods #############################################
  def params_merge(params, scope_set)
    scope_keys, scope_values, = scope_set[0], scope_set[1], keys=[]
    scope_keys.each_with_index do |k, i|
      if !params.dig(*keys.append(k))
        if params.has_key?(scope_keys[0])
          keys[0..i-1].inject(params, :fetch)[k] = scope_values[i]
        else
          params[k] = scope_values[i]
        end
      end
    end
    params
  end

  def scope_set(scope_keys, last_set)
    scope_keys.map{|k| [k, {}]}.append(last_set).transpose
  end

  def scope_keys(f, target_type, opt_scope)
    if target_type == 'Option' && opt_scope.include?(f.kind)
      ['options']
    elsif target_type == 'Option' && !opt_scope.include?(f.kind)
      ['field_sets', f.kind, 'options']
    elsif target_type == 'FieldSet' || f.type == 'SelectMenu'
      ['field_sets', f.kind]
    elsif target_type == 'SelectField'
      ['field_sets', f.kind, 'options']
    elsif f.field_name.split(" ")[0] == 'material'
      ['field_sets', f.kind, 'tags']
    elsif f.field_name.split(" ")[0] == 'mounting'
      ['field_sets', 'mounting', 'tags']
    else
      ['field_sets', f.kind, 'tags']
    end
  end

  def detect_obj(i_fields, kind, *types)
    i_fields.detect{|f| f.kind == kind && types.include?(f.type)}
  end

  def form_inputs(inputs, scope_keys, f_kind, f_hsh) #scope_keys[0..1]
    if scope_keys[0] == 'options'
      inputs[scope_keys[0]] << f_hsh
    elsif !inputs['field_sets'].has_key?(f_kind) #!inputs.dig(*scope_keys)
      inputs['field_sets'][f_kind] = [f_hsh] #['field_kinds', f_kind]
    elsif inputs.dig(*scope_keys)
      scope_keys.inject(inputs, :fetch) << f_hsh
    end
  end

  def select_hsh(f,v)
    {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: v}
  end

  def set_hsh(f,set=[])
    {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: set}
  end

  def store_hsh(f,k,v)
    {render_as: render_as(f), label: f.field_name, method: k, selected: v}
  end

  def render_as(f)
    f.type.underscore
  end

  def fk_id(word)
    [word.singularize, 'id'].join("_")
  end

  def name_method(f)
    if render_types.include?(f.type.underscore)
      fk_id(f.kind)
    else
      delim_format(words: f.field_name, join_delim: '_', split_delims: [' ', '-'])
    end
  end

  # tagline & description hsh specific methods ver 3 ########################### Item.find(5).product_group['description']

  def media_keys
    %w[embellished category sub_category medium material]
  end

  def description_hsh(opt_params, fs_params, hsh={})
    media_keys.map{|k| media_hsh(opt_params.select{|k,v| !v.nil?}, k, hsh)}
    fs_params.each do |kind, kind_hsh|
      case_hsh(kind_hsh, kind, hsh)
    end
    hsh
  end

  def case_hsh(kind_hsh, kind, hsh)
    return if kind_hsh.has_key?(kind+'_id') && kind_hsh[kind+'_id'].nil?
    kind_hsh.each do |f_key, f_hsh|
      next if f_hsh.class != Hash || f_hsh.values.any?{|v| v.blank?}
      if f_key == 'options'
        hsh.merge!(field_name_value(kind, f_hsh[kind+'_id'].field_name))
      elsif f_key == 'tags'
        tags_hsh(f_hsh, hsh, kind, 'tags')
      end
    end
    hsh
  end

  def media_hsh(source_hsh, k, hsh)
    if source_hsh.has_key?(fk_id(k))
      hsh.merge!(field_name_value(k, source_hsh[fk_id(k)].field_name))
    elsif product.tags.has_key?(k) && product.tags[k] != 'n/a'
      hsh.merge!(field_name_value(k, product.tags[k].underscore.split('_').join(' ')))
    end
  end

  def tags_hsh(tags_hsh, hsh, *keys)
    if hsh.has_key?(keys[0])
      hsh[keys[0]][keys[1]] = tags_hsh
    else
      hsh[keys[0]] = {keys[1] => tags_hsh}
    end
  end

  def field_name_value(k,v)
    {k=>{'field_name'=>v}}
  end
  
  # tagline & description hsh specific methods ver 2 ###########################
  # def media_keys
  #   %w[embellished category sub_category medium material]
  # end
  #
  # def option_keys
  #   %w[leafing remarque signature certificate]
  # end
  #
  # def option_and_tag_keys
  #   %w[mounting numbering]
  # end
  #
  # def tag_keys
  #   %w[dimension]
  # end

  # def description_hsh(i_params, hsh={})
  #   description_keys = media_keys + option_keys + option_and_tag_keys + tag_keys
  #   description_keys.each do |k|
  #     if media_keys.include?(k)
  #       media_hsh(i_params['options'].select{|k,v| !v.nil?}, k, hsh)
  #     elsif option_keys.include?(k)
  #       opts_hsh(i_params['field_sets'], hsh, k, 'options', fk_id(k))
  #     elsif option_and_tag_keys.include?(k)
  #       opts_and_tags_hsh(i_params['field_sets'], k, hsh)
  #     elsif tag_keys.include?(k)
  # 	    tags_hsh(i_params['field_sets'], hsh, k, 'tags')
  #     end
  #   end
  #   hsh
  # end
  #

  #
  # def opts_hsh(source_hsh, hsh, *keys)
  #   if source_hsh.has_key?(keys[0]) && !source_hsh.dig(*keys).nil?
  #     hsh.merge!(field_name_value(keys[0], source_hsh.dig(*keys).field_name))
  #   end
  # end
  #
  # def opts_and_tags_hsh(source_hsh, k, hsh)
  #   return if source_hsh[k][fk_id(k)].nil? #reject? akin to media_hsh?
  #   source_hsh[k].each do |f_key, v|
  #     if f_key == 'options' #&& !source_hsh[k][f_key][fk_id(k)].nil?
  #       opts_hsh(source_hsh, hsh, k, f_key, fk_id(k))
  #     elsif f_key == 'tags' #<-- here!
  #       tags_hsh(source_hsh, hsh, k, f_key)
  #     end
  #   end
  #   hsh
  # end



  # tagline & description hsh specific methods #################################
  # def description_hsh(i_params, hsh={})
  #   #hsh={'artist'=>{'field_name' => artist.try(:artist_name)}, 'title'=>{'field_name' =>title}}
  #   option_items_hsh(i_params['options'].select{|k,v| !v.nil?}, hsh)
  #   field_set_items_hsh(i_params['field_sets'], hsh)
  # end

  # def option_items_hsh(opt_params, hsh)
  #   opt_params.each do |k,v|
  #     hsh.merge!({v.kind =>{'field_name' => v.field_name}})
  #   end
  # end
  #
  # def field_set_items_hsh(kind_hsh, hsh)
  #   kind_hsh.each do |kind, param_hsh|
  #     next if param_hsh.has_key?(fk_id(kind)) && param_hsh[fk_id(kind)].nil?
  #     param_hsh.each do |param_key, param_value| #dim_id, <obj>
  #       if param_key == 'options' && !param_hsh[param_key][fk_id(kind)].nil?
  #         hsh.merge!({kind=>{'field_name'=> param_hsh[param_key][fk_id(kind)].field_name}})
  #       elsif param_key == 'tags'
  #         set_hsh(hsh, param_hsh, kind, param_key)
  #       end
  #     end
  #   end
  #   hsh
  # end
  #
  # def set_hsh(hsh, param_hsh, k, k2)
  #   if hsh.has_key?(k)
  #     hsh[k][k2] = param_hsh[k2]
  #   else
  #    hsh[k] = {k2 => param_hsh[k2]}
  #   end
  # end
end
