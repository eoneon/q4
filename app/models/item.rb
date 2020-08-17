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

  # attribute :standard_product
  # attribute :product
  # attribute :options
  # attribute :select_menus


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

  # product_group ############################################################## Item.find(3).product_group
  def product_group
    params, inputs = {}, {'options'=>[], 'field_sets'=>{}}
    return {'params'=>params, 'inputs'=>inputs} if !product
    p_fields, i_fields, opt_scope = product.field_targets, field_targets, product.select_fields.pluck(:kind) << 'material'
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

end


  #previous draft methods ######################################################
  # def collection_field_types
  #   ['SelectField', 'FieldSet', 'SelectMenu']
  # end
  #
  # #previous draft methods ######################################################
  # def field_param(f, f_type, f_kind, set)
  #   {"#{f_kind}_id" => detect_obj(set, f_kind, f_type)}
  # end
  #
  # def build_tag_param(f)
  #   v = tags.present? && tags.has_key(f.field_name) ? tags[f.field_name] : nil
  #   {f.field_name.split(" ").join("_") => v}
  # end

  ##############################################################################
  #replaced by product_params ??
  # def field_params
  #   if product
  #     product_params = build_options_params(product.field_params)
  #     product_params = build_field_sets_params(product_params)
  #     build_field_sets_options_params(product_params)
  #   end
  # end
  #
  # def build_options_params(product_params)
  #   product_params["options"].keys.each do |k|
  #     f = dyno_find_by_kind("options", k)
  #     product_params["options"][k] = f.try(:id)
  #   end
  #   product_params
  # end
  #
  # def build_field_sets_params(product_params)
  #   product_params["field_sets"].select{|k,v| k != "options"}.keys.each do |k|
  #     #"field_sets"=>{"dimension_id"=>9678, "mounting_id"=>nil, "numbering_id"=>nil}
  #     f = dyno_find_by_kind("field_sets", k)
  #     product_params["field_sets"][k] = f.try(:id)
  #     #if f then f.targets;
  #     #if target.type == 'SelectMenu' then add new hash? material, mounting, numbering
  #     #add nested tags hash inside above?
  #   end
  #   product_params
  # end
  #
  # def build_field_sets_options_params(product_params, tags_hsh={"tags" => nil})
  #   product_params["field_sets"]["options"].keys.each do |k|
  #     f = dyno_find_by_kind("options", k)
  #     product_params["field_sets"]["options"][k] = f.try(:id)
  #
  #     if fs_fields = build_field_sets_fields_params(f)
  #       build_tag_params(fs_fields, tags_hsh)
  #     end
  #
  #   end
  #   product_params
  # end
  #
  # def build_tag_params(fs_fields, tags_hsh)
  #   fs_fields.each do |f|
  #     tags_hsh["tags"][f.kind].merge(h={f.name => tags[f.name]})
  #   end
  #   tags_hsh
  # end
  #
  # def build_field_sets_fields_params(f)
  #   if f && f.targets.any?
  #     f.targets.select{|ff| tag_fields.include?(ff.type)}
  #   end
  # end
  #
  # def dyno_find_by_kind(assoc, k)
  #   public_send(assoc).find_by(kind: un_id(k))
  # end
  #
  # def un_id(k)
  #   k.sub('_id','')
  # end

  # def tag_fields
  #   ['NumberField', 'TextField', 'TextAreaField']
  # end
  #
  # #kill??
  # def product_id
  #   product.id if product
  # end
  #
  # #kill??
  # def artist_id
  #   artist.id if artist
  # end
  # #kill??
  # def field_param_key(f)
  #   [field.kind, field.type.underscore].join('_')
  # end

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

  # def field_set_group(fs, i_fields, params, inputs, opt_scope)
  #   fs.targets.each do |f|
  #     if f.type == 'SelectField'
  #       select_field_group(f, i_fields, params, inputs, opt_scope)
  #     elsif f.type == 'SelectMenu' #dimension, mounting, numbering
  #       select_menu_group(f, i_fields, params, inputs, opt_scope)
  #     elsif f.type != 'FieldSet'
  #       tags_group(f, params, inputs)
  #     end
  #   end
  # end

  # def select_field_group(sf, i_fields, params, inputs, opt_scope)
  #   #target_type = sf.targets.first.type
  #   opt = detect_obj(i_fields, sf.kind, 'Option')
  #   scope_keys = scope_keys(sf, 'Option', opt_scope)
  #
  #   #params_merge(inputs, input_scope(sf, scope_keys), select_hsh(sf,opt))
  #   params_merge(params, scope_keys, {sf.kind+'_id'=>opt})
  #   #puts "inputs: #{inputs}"
  # end



  # def field_set_group(fs, i_fields, params, inputs, opt_scope)
  #   fs.targets.each do |f|
  #     if f.type == 'SelectField'
  #       select_field_group(f, i_fields, params, inputs, opt_scope)
  #     elsif f.type == 'SelectMenu' #dimension, mounting, numbering
  #       select_menu_group(f, i_fields, params, inputs, opt_scope)
  #     elsif f.type != 'FieldSet'
  #       tags_group(f, params, inputs)
  #     end
  #   end
  # end

  # def select_menu_group(sm, i_fields, params, inputs, opt_scope)
  #   ff = detect_obj(i_fields, sm.kind, 'FieldSet', 'SelectField')
  #   params_merge(params, ['field_sets', sm.kind], {sm.kind+'_id'=>ff})
  #   params_merge(inputs, input_scope(sm, [sm.kind]), select_hsh(sm,ff))
  #
  #   if ff && ff.type == 'FieldSet'
  #     field_set_group(ff, i_fields, params, inputs, opt_scope)
  #   elsif ff && ff.type == 'SelectField'
  #     select_field_group(ff, i_fields, params, inputs, opt_scope)
  #   end
  # end

  # def tags_group(f, params, inputs)
  #   v = tags.present? && tags.has_key(f.field_name) ? tags[f.field_name] : nil
  #   k = f.field_name.split(" ").join("_")
  #
  #   params_merge(params, ['field_sets', f.kind, 'tags'], {k => v})
  #   params_merge(inputs, [f.kind], store_hsh(f,k))
  # end

# def nested_merge(params, i, keys, key_exist, k, hsh)
#   if i == 0 && !key_exist
#     params[k] = hsh #params.merge!(hsh)
#   elsif i == 0 && key_exist
#     params[k].merge!(hsh)
#   elsif !key_exist #keys.inject(params, :fetch).merge!({k=>hsh})
#     keys.inject(params, :fetch)[k] = hsh
#   elsif key_exist
#     keys.inject(params, :fetch)[k].merge!(hsh)
#   end
# end
#
# def recursive_merge(merge_from, merge_to)
#   merged_hash = merge_to.clone
#   first_key = merge_from.keys[0]
#   if merge_to.has_key?(first_key)
#     merged_hash[first_key] = recursive_merge(merge_from[first_key], merge_to[first_key])
#   else
#     merged_hash[first_key] = merge_from[first_key]
#   end
#   merged_hash
# end

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
