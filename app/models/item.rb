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

  def product_params
    if product
      p_fields, i_fields, params = product.field_targets, field_targets, {}
      p_fields.each do |f|
        if f.type == 'SelectField'
          params_merge(params, ['options'], field_param(f, 'Option', f.kind, i_fields))
        elsif f.type == 'FieldSet'
          field_set_params(f.targets, i_fields, params)
        elsif f.type == 'SelectMenu'
          select_menu_params(f, i_fields, params, f.targets.first.type)
        end
      end
    end
    params
  end

  def params_merge(params, key_set, hsh)
    key_set.each_with_index do |k, i|
      idx = i == 0 ? 0 : i-1 
      keys, trigger, key_exist = key_set[0..idx], key_set[-1] == k, nested_keys?(params, key_set[0..i])

      if trigger && !key_exist #unitialized kv pair/hash
        nested_merge(params, i, keys, {k=>hsh})
      elsif trigger && key_exist
        nested_merge(params, i, keys, hsh)
      elsif !trigger && !key_exist
        nested_merge(params, i, keys, {k=>{}})
      end
    end
  end

  def nested_keys?(params, keys)
    params.dig(*keys)
  end

  def nested_merge(params, i, keys, hsh)
    if i == 0
      params.merge!(hsh)
    else
      keys.inject(params, :fetch).merge!(hsh)
    end
  end

  # def params_merge(params, key_set, hsh)
  #   params = cascade_init(params, key_set)
  #   k = key_set.pop(1)
  #   if key_set.count == 0
  #     params[k].merge!(hsh)
  #   else
  #     key_set.inject(params, :fetch)[k].merge!(hsh)
  #   end
  # end
  #
  #
  # def cascade_init(params, key_set)
  #   key_set.each_with_index do |k, i|
  #     next if i == 0 && params.has_key?(k)
  #     if i == 0 && !params.has_key?(k)
  #       params.merge!({k=>{}})
  #     elsif !params.dig(*key_set[0..i])
  #       key_set[0..i-1].inject(params, :fetch)[k] = {}
  #     end
  #   end
  # end

  def field_set_params(fields, i_fields, params)
    fields.each do |f|
      if f.type == 'SelectField'
        h = field_param(f, 'Option', f.kind, i_fields)
        key_set = f.kind == 'material' ? ['options'] : ['field_sets', f.kind, 'options']
        #cascade_init(params, key_set)
        params_merge(params, key_set, h)
        #f.kind == 'material' ? params_merge(params, ['options'], h) : params_merge(params, ['field_sets', f.kind, 'options'], h) #assign_or_merge(params['field_sets'][f.kind], 'options', h)
      elsif f.type == 'SelectMenu' #dimension, mounting, numbering
        select_menu_params(f, i_fields, params, f.targets.first.type)
      elsif f.type != 'FieldSet'
        h = build_tag_param(f)
        #cascade_init(params, ['field_sets', f.kind, 'tags'])
        params_merge(params, ['field_sets', f.kind, 'tags'], h)
        #params['field_sets'][f.kind].has_key?('tags') ? params['field_sets'][f.kind]['tags'].merge!(h) : params['field_sets'][f.kind]['tags'] = h
      end
    end
    params
  end

  def select_menu_params(f, i_fields, params, target_type)
    h = field_param(f, target_type, f.kind, i_fields)
    if target_type == 'FieldSet'
      #cascade_init(params, ['field_sets', f.kind])
      params_merge(params, ['field_sets', f.kind], h)
      #assign_or_merge(params['field_sets'], f.kind, h)

      if ff = params['field_sets'][f.kind][f.kind+'_id']
        field_set_params(ff.targets, i_fields, params) #ff => dimension::fields_set.targets
      end
    else f.type == 'SelectField'
      #cascade_init(params, ['field_sets', f.kind, 'options'])
      params_merge(params, ['field_sets', f.kind, 'options'], h)
      #assign_or_merge(params['field_sets'], f.kind, h)
    end
  end

  def detect_obj(i_fields, type, kind)
    i_fields.detect{|f| f.type == type && f.kind == kind}
  end

  def field_param(f, f_type, f_kind, set)
    h={"#{f_kind}_id" => detect_obj(set, f_type, f_kind)}
  end

  def assign_or_merge(params, k, hsh)
    #puts "params1: #{params}"
    if params.has_key?(k)
      params.merge!(hsh)
    else
      params[k] = hsh
    end
    #puts "params2: #{params}"
  end

  # def assign_or_merge(params, k, hsh)
  #   #puts "params1: #{params}"
  #   if params.has_key?(k)
  #     params.merge!(hsh)
  #   else
  #     params[k] = hsh
  #   end
  #   #puts "params2: #{params}"
  # end

  def build_tag_param(f)
    v = tags.present? && tags.has_key(f.field_name) ? tags[f.field_name] : nil
    h={f.field_name.split(" ").join("_") => v}
  end

  ##############################################################################

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

  def product_id
    product.id if product
  end

  def artist
    artists.first if artists.any?
  end

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
