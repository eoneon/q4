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

  # Item.find(5).field_targets ## h = Item.find(5).product_group['description'] ## h['inputs'] ## h['inputs']['field_sets']
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

  # tagline & description hsh specific methods ver 3 ########################### h = Item.find(5).product_group['description']
  def description_hsh(opt_params, fs_params, hsh={})
    item_hsh(hsh)
    media_hsh(opt_params.select{|k,v| !v.nil?}, hsh)
    sub_media_hsh(fs_params, hsh)
    tag_line(hsh, hsh.keys)
  end

  def item_hsh(hsh)
    [['artist', artist.try(:artist_name)], ['title', title]].map{|set| hsh.merge!(field_name_value(set[0], set[1]))}
  end

  def media_hsh(source_hsh, hsh)
    %w[embellished category sub_category medium material].each do |kind|
      merge_media_to_hsh(source_hsh, hsh, kind)
    end
    hsh
  end

  def merge_media_to_hsh(source_hsh, hsh, kind)
    if source_hsh.has_key?(kind+'_id')
      f_hsh_from_source_hsh(source_hsh, hsh, kind)
    elsif product.tags.has_key?(kind) && product.tags[kind] != 'n/a'
      f_hsh_from_from_product_hsh(hsh, kind)
    end
  end

  #################################################

  def sub_media_hsh(source_hsh, hsh)
    source_hsh.each do |kind, kind_hsh|
      merge_options_and_tags_hsh(kind_hsh, hsh, kind)
      #f_hsh_from_source_hsh(kind_hsh.dig('options'), hsh, kind) if kind_hsh.dig('options') && !kind_hsh.dig('options').values.any?{|v| v.blank?}
      #tags_hsh(kind_hsh.dig('tags'), hsh, kind, 'tags') if kind_hsh.dig('tags') && !kind_hsh.dig('tags').values.any?{|v| v.blank?}
    end
    hsh
  end

  def merge_options_and_tags_hsh(kind_hsh, hsh, kind)
    %w[options tags].each do |f_key|
      next if !kind_hsh.dig(f_key) || kind_hsh.dig(f_key).values.any?{|v| v.blank?}
      f_hsh_from_source_hsh(kind_hsh.dig(f_key), hsh, kind) if f_key == 'options'
      tags_hsh(kind_hsh.dig(f_key), hsh, kind, 'tags') if f_key == 'tags'
    end
    hsh
  end

  # def merge_sub_media_to_hsh(source_hsh, hsh, kind)
  #   source_hsh.each do |f_key, f_hsh|
  #     next if f_hsh.class != Hash || f_hsh.values.any?{|v| v.blank?}
  #     sub_media_merge_cases(f_hsh, f_key, kind, hsh)
  #   end
  #   hsh
  # end

  # def sub_media_merge_cases(source_hsh, f_key, kind, hsh)
  #   if f_key == 'options'
  #     f_hsh_from_source_hsh(source_hsh, hsh, kind)
  #   elsif f_key == 'tags'
  #     tags_hsh(source_hsh, hsh, kind, 'tags')
  #   end
  # end

  def f_hsh_from_source_hsh(source_hsh, hsh, k)
    hsh.merge!(field_name_value(k, source_hsh[fk_id(k)].field_name))
  end

  def f_hsh_from_from_product_hsh(hsh, k)
    hsh.merge!(field_name_value(k, product.tags[k].underscore.split('_').join(' ')))
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

  ##############################################################################

  def tag_line(d_hsh, d_keys, set=[])
    title_keys.each do |k|
      set << tag_line_values(k, d_hsh[k]['field_name'], d_hsh.dig(k, 'tags'), d_keys) if d_keys.include?(k)
    end
    set #[set, d_keys, d_hsh]
  end

  def tag_line_values(k, field_name, tags, d_keys)
    #puts "#{k_hsh}"
    #field_names = k_hsh['field_name']

    if k == 'artist' && !field_name.blank?
      "#{field_name},"
    elsif k == 'title' && !field_name.blank?
      "\"#{field_name}\""
    elsif k == 'category' && field_name == 'one of a kind'
      'One-of-a-Kind'
    elsif k == 'material'
      "on #{field_name}"
    elsif k == 'leafing'
      "with #{field_name}"
    elsif k == 'remarque'
      d_keys.include?('leafing') ? "and #{field_name}" : "with #{field_name}"
    elsif k == 'numbering'
      tags ? "#{field_name} #{tags.values.join('/')}" : field_name
    elsif k == 'signature'
      d_keys.include?('numbering') ? "and #{field_name}" : field_name
    elsif k == 'certificate'
      "with #{field_name}"
    else
      field_name
    end
  end

  def title_keys
    %w[artist title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate]
  end

  def description_keys
    %w[title artist embellished category sub_category medium material dimension leafing remarque numbering signature mounting certificate dimension]
  end
end
