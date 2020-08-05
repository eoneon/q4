class Item < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :standard_products, through: :item_groups, source: :target, source_type: "StandardProduct"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  attribute :standard_product
  attribute :product
  attribute :options
  attribute :select_menus

  def product_group
    return if !product
    p_fields, i_fields, opt_scope, params, inputs = product.field_targets, field_targets, product.select_fields.pluck(:kind) << 'material', {}, {}
    p_fields.each do |f|
      if f.type == 'SelectField'
        select_field_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'FieldSet'
        field_set_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'SelectMenu'
        select_menu_group(f, i_fields, params, inputs, opt_scope)
      end
    end
    {'params'=>params, 'inputs'=>inputs}
  end

  def select_field_group(sf, i_fields, params, inputs, opt_scope)
    target_type = sf.targets.first.type
    #opt = detect_obj(i_fields, target_type, sf.kind)
    opt = detect_obj(i_fields, sf.kind, target_type)
    #need to sniff out options-context here: product.select_fields.pluck(:kind).append('material')

    #scope_keys = sf.kind == 'material' ? ['options'] : ['field_sets', sf.kind, 'options']
    scope_keys = scope_keys(sf, target_type, opt_scope)
    params_merge(params, scope_keys, {sf.kind+'_id'=>opt})
    #params_merge(inputs, input_scope(f, scope_keys), opt_hsh(sf,opt))
  end

  def field_set_group(fs, i_fields, params, inputs, opt_scope)
    fs.targets.each do |f|
      if f.type == 'SelectField'
        select_field_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type == 'SelectMenu' #dimension, mounting, numbering
        select_menu_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type != 'FieldSet'
        tags_group(f, params, inputs)
      end
    end
  end

  def select_menu_group(sm, i_fields, params, inputs, opt_scope)
    #target_type = sm.targets.first.type
    # issue: how do you find ff if we don't know if we're lookin for a Fieldset or an Option?? make that arg an array? and then select first?? applicable only for numbering??
    #ff = detect_obj(i_fields, 'FieldSet', sm.kind)
    ff = detect_obj(i_fields, sm.kind, 'FieldSet', 'SelectField')
    params_merge(params, ['field_sets', sm.kind], {sm.kind+'_id'=>ff})

    if ff && ff.type == 'FieldSet'
      #scope_keys = scope_keys(ff, ff.targets.first.type, opt_scope)
      field_set_group(ff, i_fields, params, inputs, opt_scope)
    elsif ff && ff.type == 'SelectField'
      select_field_group(ff, i_fields, params, inputs, opt_scope)
      # scope_keys = scope_keys(ff, ff.targets.first.type, opt_scope)
      # params_merge(params, ['field_sets', f.kind, 'options'], h)
    end
    #scope_keys = target_type == 'FieldSet' ? ['field_sets', ff.kind] : ['field_sets', ff.kind, 'options']
    #puts "test: #{sm.field_name}" #
    #scope_keys = scope_keys(sm, target_type, opt_scope)

     #if target_type == 'FieldSet'
    #params_merge(inputs, input_scope(f, scope_keys), opt_hsh(sm,ff))
  end

  def tags_group(f, params, inputs)
    v = tags.present? && tags.has_key(f.field_name) ? tags[f.field_name] : nil
    k = f.field_name.split(" ").join("_")
    #scope_keys = scope_keys(f, 'tag', opt_scope)
    #params_merge(params, ['field_sets', f.kind, 'tags'], {k => v})
    params_merge(params, ['field_sets', f.kind, 'tags'], {k => v})
    #params_merge(inputs, f.kind, store_hsh(f,k))
  end

  def scope_keys(f, target_type, opt_scope)
    if target_type == 'Option' && opt_scope.include?(f.kind)
      ['options']
    elsif target_type == 'Option'
      ['field_sets', f.kind, 'options']
    elsif target_type == 'FieldSet' || f.type == 'SelectMenu'
      ['field_sets', f.kind]
    elsif target_type == 'SelectField'
      ['field_sets', f.kind, 'options']
    else
      ['field_sets', f.kind, 'tags']
    end
  end

  def detect_obj(i_fields, kind, *types)
    i_fields.detect{|f| f.kind == kind && types.include?(f.type)}
  end

  def input_scope(f, scope_keys)
    if scope_keys[0] == 'options'
      scope_keys[0..0]
    else
      f.kind
    end
  end

  def opt_hsh(f,v)
    {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f.options, selected: v}
  end

  def store_hsh(f,k)
    {render_as: render_as(f), label: f.field_name, method: k}
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

  def collection_field_types
    ['SelectField', 'FieldSet', 'SelectMenu']
  end

  ##############################################################################

  # def product_group
  #   return if !product
  #   p_fields, i_fields, params = product.field_targets, field_targets, {}
  #   p_fields.each do |f|
  #     if f.type == 'SelectField'
  #       params_merge(params, ['options'], field_param(f, 'Option', f.kind, i_fields))
  #     elsif f.type == 'FieldSet'
  #       field_set_params(f.targets, i_fields, params)
  #     elsif f.type == 'SelectMenu'
  #       select_menu_params(f, i_fields, params, f.targets.first.type)
  #     end
  #   end
  #   params
  # end
  #
  # def field_set_params(fields, i_fields, params)
  #   fields.each do |f|
  #     if f.type == 'SelectField'
  #       h = field_param(f, 'Option', f.kind, i_fields)
  #       key_set = f.kind == 'material' ? ['options'] : ['field_sets', f.kind, 'options']
  #       params_merge(params, key_set, h)
  #     elsif f.type == 'SelectMenu' #dimension, mounting, numbering
  #       select_menu_params(f, i_fields, params, f.targets.first.type)
  #     elsif f.type != 'FieldSet'
  #       h = build_tag_param(f)
  #       params_merge(params, ['field_sets', f.kind, 'tags'], h)
  #     end
  #   end
  #   params
  # end
  #
  # def select_menu_params(f, i_fields, params, target_type)
  #   h = field_param(f, target_type, f.kind, i_fields)
  #
  #   if target_type == 'FieldSet'
  #     params_merge(params, ['field_sets', f.kind], h)
  #
  #     if ff = params['field_sets'][f.kind][f.kind+'_id']
  #       field_set_params(ff.targets, i_fields, params) #ff => dimension::fields_set.targets
  #     end
  #
  #   elsif f.type == 'SelectField'
  #     params_merge(params, ['field_sets', f.kind, 'options'], h)
  #   end
  # end

  # def detect_obj(i_fields, type, kind)
  #   i_fields.detect{|f| f.type == type && f.kind == kind}
  # end

  # def field_param(f, f_type, f_kind, set)
  #   {"#{f_kind}_id" => detect_obj(set, f_type, f_kind)}
  # end

  def field_param(f, f_type, f_kind, set)
    {"#{f_kind}_id" => detect_obj(set, f_kind, f_type)}
  end

  def build_tag_param(f)
    v = tags.present? && tags.has_key(f.field_name) ? tags[f.field_name] : nil
    {f.field_name.split(" ").join("_") => v}
  end

  ##############################################################################

  def params_merge(params, key_set, hsh)
    key_set.each_with_index do |k, i|
      idx = i == 0 ? 0 : i-1
      keys, trigger, key_exist = key_set[0..idx], key_set[-1] == k, nested_keys?(params, key_set[0..i])
      if trigger && !key_exist
        nested_merge(params, i, keys, key_exist, k, hsh)
      elsif trigger && key_exist
        nested_merge(params, i, keys, key_exist, k, hsh)
      elsif !trigger && !key_exist
        nested_merge(params, i, keys, key_exist, k, {})
      end
    end
  end

  def nested_keys?(params, keys)
    params.dig(*keys)
  end

  def nested_merge(params, i, keys, key_exist, k, hsh)
    if i == 0 && !key_exist
      params[k] = hsh #params.merge!(hsh)
    elsif i == 0 && key_exist
      params[k].merge!(hsh)
    elsif !key_exist #keys.inject(params, :fetch).merge!({k=>hsh})
      keys.inject(params, :fetch)[k] = hsh
    elsif key_exist
      keys.inject(params, :fetch)[k].merge!(hsh)
    end
  end

  ##############################################################################
  #replaced by product_params ??
  def field_params
    if product
      product_params = build_options_params(product.field_params)
      product_params = build_field_sets_params(product_params)
      build_field_sets_options_params(product_params)
    end
  end

  def build_options_params(product_params)
    product_params["options"].keys.each do |k|
      f = dyno_find_by_kind("options", k)
      product_params["options"][k] = f.try(:id)
    end
    product_params
  end

  def build_field_sets_params(product_params)
    product_params["field_sets"].select{|k,v| k != "options"}.keys.each do |k|
      #"field_sets"=>{"dimension_id"=>9678, "mounting_id"=>nil, "numbering_id"=>nil}
      f = dyno_find_by_kind("field_sets", k)
      product_params["field_sets"][k] = f.try(:id)
      #if f then f.targets;
      #if target.type == 'SelectMenu' then add new hash? material, mounting, numbering
      #add nested tags hash inside above?
    end
    product_params
  end

  def build_field_sets_options_params(product_params, tags_hsh={"tags" => nil})
    product_params["field_sets"]["options"].keys.each do |k|
      f = dyno_find_by_kind("options", k)
      product_params["field_sets"]["options"][k] = f.try(:id)

      if fs_fields = build_field_sets_fields_params(f)
        build_tag_params(fs_fields, tags_hsh)
      end

    end
    product_params
  end

  def build_tag_params(fs_fields, tags_hsh)
    fs_fields.each do |f|
      tags_hsh["tags"][f.kind].merge(h={f.name => tags[f.name]})
    end
    tags_hsh
  end

  def build_field_sets_fields_params(f)
    if f && f.targets.any?
      f.targets.select{|ff| tag_fields.include?(ff.type)}
    end
  end

  def dyno_find_by_kind(assoc, k)
    public_send(assoc).find_by(kind: un_id(k))
  end

  def un_id(k)
    k.sub('_id','')
  end

  def tag_fields
    ['NumberField', 'TextField', 'TextAreaField']
  end

  ##############################################################################

  def product
    if product = targets.detect{|target| target.class.method_defined?(:type) && target.base_type == 'Product'}
      product
    end
  end

  #kill??
  def product_id
    product.id if product
  end

  def artist
    artists.first if artists.any?
  end
  #kill??
  def artist_id
    artist.id if artist
  end

  # def field_target_params(h={})
  #   field_targets.each do |field|
  #     h[field_param_key(f)] = field.id
  #   end
  #   h
  # end

  # def field_target_params
  #   f_params, fields = h={field_sets: hsh={options: nil}, options: nil}, field_sets
  #   %w[dimension mounting numbering].each do |kind|
  #     f = fields.find_by(kind: kind)
  #     f_params[:field_sets][kind] = id = f ? f.id : nil
  #   end
  #   f_params
  # end

  # def field_target_params
  #   #f_params={'options' => nil, 'field_sets' => h={'field_sets' => nil, 'options' => nil}}
  #   f_params={'field_sets' => field_set_params}
  #   f_params['field_sets']['options'] = h={'options' => field_set_options_params}
  #   f_params
  # end
  #
  # def field_set_params
  #   %w[dimension mounting numbering].map{|k| [k, field_sets.find_by(kind: k)]}.to_h
  # end
  #
  # def field_set_options_params
  #   %w[dimension mounting numbering].map{|k| [k, options.find_by(kind: k)]}.to_h
  # end

  # def options_params
  #   %w[dimension mounting numbering].map{|k| [k, options.find_by(kind: k)]}.to_h
  # end

  def field_targets
    scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many)
  end

  def field_param_key(f)
    [field.kind, field.type.underscore].join('_')
  end

end

# def self.recursive_merge(merge_from, merge_to)
#   merged_hash = merge_to.clone
#   first_key = merge_from.keys[0]
#   if merge_to.has_key?(first_key)
#     merged_hash[first_key] = recursive_merge(merge_from[first_key], merge_to[first_key])
#   else
#     merged_hash[first_key] = merge_from[first_key]
#   end
#   merged_hash
# end
#
# def self.test(params, key_set, args=[])
#   key_set.inject(params) do |memo, k|
#     if !params.dig(*args.append(k))
#       memo[k] = {}
#     end
#     memo
#   end
# end
#
# def self.test2(params,key_set,args=[])
#   key_set[0..-2].inject(params) do |h, (k,v)|
#     if !params.dig(*args.append(k))
#       params[k] = {}
#     else
#       params.fetch(k)
#     end
#   end
# end

# def self.recursive_merge(merge_from, merge_to)
#   merged_hash = merge_to.clone
#   first_key = merge_from.keys[0]
#   if merge_to.has_key?(first_key) && merge_from[first_key] != merge_to[first_key]
#     puts "#{1}"
#     merge_to[first_key].merge!(merge_from[first_key])
#     merge_to[first_key].merge!(merge_from[first_key])
#
#     merged_hash[first_key] = recursive_merge(merge_from[first_key], merge_to[first_key])
#   elsif merge_to.has_key?(first_key) && merge_from[first_key] == merge_to[first_key]
#     merged_hash[first_key] = recursive_merge(merge_from[first_key], merge_to[first_key])
#   else
#     merged_hash[first_key] = merge_from[first_key]
#   end
#   merged_hash
# end

# def self.cascade_init(params, key_set, args=[])
#   key_set.each do |k|
#     if !params.dig(*args.append(k))
#       params_merge(params, args, {})
#   	end
#   end
#   params
# end


# def self.cascade_init(params, key_set, h, args=[])
#   key_set.each do |k|
#     hsh = !params.dig(*args.append(k)) ? {} : h
#     params_merge(params, args, hsh)
#   end
#   params
# end

# def self.params_merge(params, key_set, hsh)
#   if key_set.count == 1
#     shallow_merge(params, key_set.first, hsh)
#   else
#     #cascade_init(params, key_set)
#     nested_merge(params, key_set, hsh)
#   end
# end

# def self.shallow_merge(params, k, hsh)
#   if params.has_key?(k)
#     params[k].merge!(hsh)
#   else
#     params.merge!({k => hsh}) #params[k] = hsh
#   end
# end
#
# def self.nested_merge(params, key_set, hsh)
#   #k = key_set.pop(1)
#   #p_hsh = key_set.inject(params, :fetch)[k].merge!(hsh)
#   p_hsh = key_set[0..-2].inject(params, :fetch)#{|k,v| {}}
#   if params.dig(*key_set) #check level during dig; key_set.detect.{|k| }
#     p_hsh[key_set.last].merge!(hsh)
#   else
#     p_hsh[key_set.last] = hsh
#   end
# end

# def params_merge(params, key_set, hsh)
#   k = key_set.pop(1)
#   key_set.inject(params, :fetch)[k].merge!(hsh)
# end


# def material_field_params(fields, i_fields, params)
#   fields.each do |f|
#     if f.type == 'SelectField'
#       h = field_param(f, 'Option', f.kind, i_fields)
#       params['options'].merge(h)
#     elsif f.type == 'SelectMenu' #dimension, mounting
#       h = field_param(f, 'FieldSet', f.kind, i_fields) #dimension_id, mounting_id
#       assign_or_merge(params['field_sets'], f.kind, h)
#       if ff = params['field_sets'][f.kind][f.kind+'_id']
#         field_set_params(ff.targets, i_fields, params) #ff => dimension::fields_set.targets
#       #if f.targets.any?
#         #field_set_params(f.targets.first.targets, i_fields, params) #f.targets.first.targets => sm.targets.first => fs => fs.targets => field_set_fields =>
#         #field_set_params(f.targets.first.targets, i_fields, params)
#       end
#     end
#   end
# end
#params['field_sets'][f.kind].has_key?('tags') ? params['field_sets'][f.kind]['tags'].merge(h) : params['field_sets'][f.kind]['tags'] = h
#params['field_sets'].has_key?(f.kind) ? params['field_sets'][f.kind].merge(h) : params['field_sets'][f.kind] = h
