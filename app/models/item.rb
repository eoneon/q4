class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ItemProduct
  include TypeCheck

  include STI
  include ExportAttrs
  include SkuRange

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :products, through: :item_groups, source: :target, source_type: "Product"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  ##############################################################################

  def self.search(scope:nil, joins:nil, hstore:nil, search_keys:nil, sort_keys:nil, attrs:{}, hattrs:{}, input_group:{})
    set = scope_group(scope, joins, input_group)
    set = attr_group(set, attrs, input_group)

    hattr_group(set, hattrs, hstore, input_group)
    format_search(input_group, input_group['search_results'], search_keys, sort_keys, hstore)
    input_group
  end

  def self.format_search(input_group, search_results, search_keys, sort_keys, hstore)
    return if !search_keys || !hstore
    uniq_search(input_group, search_results, search_keys, hstore)
    order_search(input_group['search_results'], sort_keys, hstore)
  end

  def self.uniq_search(input_group, search_results, search_keys, hstore)
    input_group['search_results'] = uniq_hattrs(search_results, search_keys, hstore) if search_keys
  end

  # def self.order_search(input_group, sort_keys, hstore)
  #   input_group['search_results'].sort_by!{|i| sort_keys.map{|k| sort_value(i.public_send(hstore)[k])}} if sort_keys
  # end

  def self.order_search(search_results, sort_keys, hstore)
    search_results.sort_by!{|i| sort_keys.map{|k| sort_value(i.public_send(hstore)[k])}} if sort_keys
  end

  def self.sort_value(val)
    is_numeric?(val) ? val.to_i : val
  end

  def self.is_numeric?(s)
    !!Float(s) rescue false
  end

  # join_search (I) ##########################################################
  def self.scope_group(scope, joins, input_group)
    input_group.merge!({'scope' => scope.try(:id), 'search_results' => scope_results(scope, joins)})
    scope_set(input_group)
  end

  def self.scope_results(scope, joins)
    joins && scope ? scope_query(scope, joins) : []
  end

  def self.scope_set(input_group)
    input_group['search_results'].blank? ? self : input_group['search_results']
  end

  def self.scope_query(scope, joins)
    self.joins(joins).where(joins => scope_query_params(scope))
  end

  def self.scope_query_params(scope)
    {target_type: scope.class.base_class.name, target_id: scope.id}
  end

  # attr_search (II) #########################################################
  def self.attr_group(set, attrs, input_group)
    return set if attrs.empty? #|| input_group['search_results'].empty?
    attr_opts = attr_options(attrs, input_group['search_results'])
    input_group.merge!({'attrs' => attr_opts, 'search_results' => attr_results(set, attrs.reject{|k,v| v.blank?}, input_group)})
    attr_set(input_group)
  end

  def self.attr_results(set, attrs, input_group)
    attrs.blank? ? input_group['search_results'] : input_group['search_results'].where(attrs)
  end

  def self.attr_set(input_group)
    input_group['search_results'].blank? ? self : input_group['search_results']
  end

  # hattr_search (III) #######################################################
  def self.hattr_group(set, hattrs, hstore, input_group)
    return if !hstore
    hattr_query_case(set, hattrs.reject{|k,v| v.blank?}, hstore, input_group)
    input_group.merge!({'hattrs' => search_options(input_group['opt_set'], hattrs, hstore)})
  end

  def self.hattr_query_case(set, hattrs, hstore, input_group)
    opt_set = hattr_search_query(set, hattrs, hstore)
    input_group.merge!({'opt_set'=> opt_set, 'search_results'=> hattr_results(hattrs, opt_set, input_group['search_results'])})
  end

  def self.hattr_search_query(set, hattrs, hstore)
    if hattrs.empty?
      index_query(set, hattrs.keys, hstore)
    else
      search_query(set, hattrs, hstore)
    end
  end

  def self.hattr_results(hattrs, opt_set, search_results)
    hattrs.empty? ? search_results : opt_set
  end

  def self.index_query(set, keys, hstore)
    set.where("#{hstore}?& ARRAY[:keys]", keys: keys)
  end

  def self.search_query(set, hattrs, hstore)
    set.where(hattrs.to_a.map{|kv| query_params(kv[0], kv[1], hstore)}.join(" AND "))
  end

  def self.query_params(k,v, hstore)
    "#{hstore} -> \'#{k}\' = \'#{v}\'"
  end

  def self.query_order(keys, hstore)
    keys.map{|k| "#{hstore} -> \'#{k}\'"}.join(', ')
  end

  def self.search_options(opt_set, hattrs, hstore, h={})
    hattrs.each do |k,v|
      h.merge!({k=>{'opts'=> select_opts(opt_set, k, hstore), 'selected'=>v}})
    end
    h
  end

  def self.select_opts(opt_set, k, hstore)
    opt_set.map{|i| i.public_send(hstore)[k]}.uniq.compact
  end

  def self.attr_options(attrs, results, h={})
    attrs.each do |k,v|
      h.merge!({k => {'opts' => attr_opts(results, k), 'selected' =>v}})
    end
    h
  end

  def self.attr_opts(results, k)
    results.pluck(k.to_sym).uniq
  end

  def self.default_query
    item_search_keys.map{|k| [k,'']}.to_h
  end

  def self.item_search_keys
    %w[search_tagline mounting material_dimensions edition]
  end

  def self.attr_search_keys
    %w[title]
  end

  def self.index_search
    item_search_keys.map{|k| [k, nil]}.to_h
  end

  def self.uniq_hattrs(set, keys, hstore, list=[], uniq_set=[])
    set.each do |i|
      assign_unique(i, keys, hstore, list, uniq_set)
    end
    uniq_set
  end

  def self.assign_unique(i, keys, hstore, list, uniq_set)
    h = keys.map{|k| [k, i.public_send(hstore)[k]]}.to_h
    return if list.include?(h)
    list << h
    uniq_set << i
  end

  #new methods: #############################################################################
  def self.index_hstore_input_group(search_keys, sort_keys, hstore, input_group:{}, search_results:nil)
    opt_set = uniq_hattrs(index_query(self, search_keys, hstore), search_keys, hstore)
    opt_set = order_search(opt_set, sort_keys, hstore)
    build_hstore_input_group(search_keys, opt_set, hstore, input_group, search_results)
  end

  def self.build_hstore_input_group(search_keys, opt_set, hstore, input_group, search_results)
    search_results = search_results.nil? ? opt_set : search_results
    input_group.merge!({'hattrs' => search_options(opt_set, default_hsh(search_keys), hstore), 'search_results' => search_results, 'scope' => nil, 'attrs' => attr_options(default_hsh(attr_search_keys), [])})
  end

  def self.default_hsh(keys, v=nil)
    keys.map{|k| [k, v]}.to_h
  end

  ##############################################################################

  def tagline
    csv_tags['tagline'] unless csv_tags.nil?
  end

  def search_tagline
    csv_tags['search_tagline'] unless csv_tags.nil?
  end

  def body
    csv_tags['body'] unless csv_tags.nil?
  end

  def field_targets
    #scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many)
    scoped_targets(scope: 'FieldItem', join: :item_groups, sort: :sort, reject_set: ['RadioButton'])
  end

  def product
    products.first if products.any? #scoped_targets(scope: 'Product', join: :item_groups).first
  end

  def artist
    artists.first if artists.any?
  end

  ##############################################################################

  def format_vowel(word, exception_set=[])
    %w[a e i o u].include?(word.first.downcase) && exception_set.exclude?(word) ? 'an' : 'a'
  end

  def cap_words(words, set=[])
    return set << words if words && words[0] == "\""
    format_word_set(words.split(' '), set)
  end

  def format_word_set(word_set, set)
    word_set.each do |word|
      set << cap_case(word)
    end
    set.join(' ')
  end

  def cap_case(word)
    if ('A'..'Z').include?(word[0]) || %w[a an and from with].include?(word)
      word
    else
      word.capitalize
    end
  end
end

# def field_items
#   field_sets + select_fields + options
# end

# def grouped_form_fields
#   form_fields.group_by{|h| h[:kind_scope]}
# end
#
# def form_fields
#   return {} unless product
#   a = product.input_group_with_params(input_params).each_with_object([]) do |(k, field_groups), a|
#     field_groups.each do |t, fields|
#       fields.values.map {|f_hsh| a.append(f_hsh)}
#     end
#   end
# end

##############################################################################

# def input_params(hsh={})
#   param_args(field_groups: g_hsh).each do |h|
#     param_merge(params: hsh, dig_set: dig_set(dig_hsh(*h.values)))
#     unpack_field_set_params(h[:f_obj].g_hsh, hsh) if h[:t] == 'field_set' #unpack_field_set_params
#   end
#   hsh #.merge!({"tags"=> self.tags})
# end
#
# def unpack_field_set_params(field_groups, hsh)
#   param_args(field_groups: field_groups).each do |h|
#     k, t, t_type, f_name, f_obj = h.values
#     if f_val = self.tags.dig(f_name)
#       param_merge(params: hsh, dig_set: dig_set(k: f_name, v: detect_assoc(t_type, f_val, f_obj), dig_keys: [k, t_type]))
#     end
#   end
#   hsh
# end
#
# def dig_hsh(k, t, t_type, f_name, f_val)
#   {k: infer_f_name(t, f_val, f_name), v: infer_f_val(t, f_val, f_name), dig_keys: [k, infer_type(t)]}
# end
#
# def infer_f_name(t, f_val, f_name)
#   input_attr?(t) ? f_name : self.tags.key(f_val.id.to_s)
# end
#
# def infer_f_val(t, f_val, f_name)
#   input_attr?(t) ? self.tags.dig(f_name) : f_val
# end
#
# def infer_type(t)
#   input_attr?(t) ? 'tags' : t
# end

# def detect_assoc(t, f_val, f_obj)
#   return f_val if t == 'tags'
#   f_obj.fieldables.detect{|f| f.id == f_val.to_i && f.type == t.classify}
# end

# Item.find(53).product_group['params']   Item.find(6).product_group['inputs']
# Item.find(5).field_targets ## pg = Item.find(5).product_group['params'] ## h['inputs'] ## h['inputs']['field_sets']   Item.find(5).product_group['inputs']['field_sets']
# product_group ############################################################## Item.find(5).product_group['inputs']['field_sets']
# def product_group
#   params, inputs = {}, {'options'=>[], 'field_sets'=>{}}
#   return {'params'=>params, 'inputs'=>inputs} if !product
#   p_fields, i_fields = product.field_targets, field_targets
#
#   p_fields.each do |f|
#     if f.type == 'SelectField'
#       select_field_group(f, i_fields, params, inputs)
#     elsif f.type == 'FieldSet'
#       field_set_group(f, i_fields, params, inputs)
#     elsif f.type == 'SelectMenu'
#       select_menu_group(f, i_fields, params, inputs)
#     elsif f.type == 'TextAreaField'
#       tags_group(f, params, inputs)
#     end
#   end
#   {'params'=>params, 'inputs'=>inputs}
# end
#
# # need graceful non-exception condition
#
# def fields_for_scope_grouped_by_kind
#   [%w[item product], [field_targets, product.field_targets].map{|fields| fields.group_by{|f| f.kind}}].transpose.to_h if product
# end
#
# # field-type specific methods ################################################
# def select_field_group(sf, i_fields, params, inputs)
#   opt = detect_obj(i_fields, sf.kind, 'Option')
#   scope_keys = %w[embellished category medium material].include?(sf.kind) ? ['options'] : ['field_sets', sf.kind, 'options']
#   scope_set = scope_set(scope_keys, [sf.kind+'_id', opt])
#   params_merge(params, scope_set)
#   form_inputs(inputs, scope_keys[0..1], sf.kind, select_hsh(sf,opt))
# end
#
# def field_set_group(fs, i_fields, params, inputs)
#   fs.targets.each do |f|
#     if f.type == 'SelectField'
#       select_field_group(f, i_fields, params, inputs)
#     elsif f.type == 'SelectMenu'
#       select_menu_group(f, i_fields, params, inputs)
#     elsif f.type == 'FieldSet'
#       field_set_group(f, i_fields, params, inputs)
#     elsif f.type != 'FieldSet'
#       tags_group(f, params, inputs)
#     end
#   end
# end
#
# def select_menu_group(sm, i_fields, params, inputs)
#   ff = detect_obj(i_fields, sm.kind, 'FieldSet', 'SelectField')
#   scope_set = scope_set(['field_sets', sm.kind], [sm.kind+'_id', ff])
#
#   params_merge(params, scope_set)
#   form_inputs(inputs, ['field_sets', sm.kind], sm.kind, select_hsh(sm,ff))
#
#   if ff && ff.type == 'FieldSet'
#     field_set_group(ff, i_fields, params, inputs)
#   elsif ff && ff.type == 'SelectField'
#     select_field_group(ff, i_fields, params, inputs)
#   end
# end
#
# def tags_group(f, params, inputs)
#   k = f.field_name.split(" ").join("_")
#   v = tags.present? && tags.has_key?(k) ? tags[k] : nil
#   scope_keys = scope_keys(f, nil)
#   scope_set = scope_set(scope_keys, [k, v])
#
#   params_merge(params, scope_set)
#   form_inputs(inputs, scope_keys[0..1], scope_keys[1], store_hsh(f,k,v))
# end
#
# # product_group specific methods #############################################
# def params_merge(params, scope_set)
#   scope_keys, scope_values, = scope_set[0], scope_set[1], keys=[]
#   scope_keys.each_with_index do |k, i|
#     if !params.dig(*keys.append(k))
#       if params.has_key?(scope_keys[0])
#         keys[0..i-1].inject(params, :fetch)[k] = scope_values[i]
#       else
#         params[k] = scope_values[i]
#       end
#     end
#   end
#   params
# end
#
# def scope_set(scope_keys, last_set)
#   scope_keys.map{|k| [k, {}]}.append(last_set).transpose
# end
#
# def scope_keys(f, target_type)
#   if target_type == 'FieldSet' || f.type == 'SelectMenu'
#     ['field_sets', f.kind]
#   elsif target_type == 'SelectField'
#     ['field_sets', f.kind, 'options']
#   elsif f.field_name.split(" ")[0] == 'material'
#     ['field_sets', f.kind, 'tags']
#   elsif f.field_name.split(" ")[0] == 'mounting'
#     ['field_sets', 'mounting', 'tags']
#   else
#     ['field_sets', f.kind, 'tags']
#   end
# end
#
# def detect_obj(i_fields, kind, *types)
#   i_fields.detect{|f| f.kind == kind && types.include?(f.type)}
# end
#
# # refactor methods: ##########################################################
# # replace :detect_obj
# # def detect_option(options, set)
# #   options.detect{|i| set.include?(i)}
# # end
# ##############################################################################
#
# def form_inputs(inputs, scope_keys, f_kind, f_hsh) #scope_keys[0..1]
#   if scope_keys[0] == 'options'
#     inputs[scope_keys[0]] << f_hsh
#   elsif !inputs['field_sets'].has_key?(f_kind) #!inputs.dig(*scope_keys)
#     inputs['field_sets'][f_kind] = [f_hsh] #['field_kinds', f_kind]
#   elsif inputs.dig(*scope_keys)
#     scope_keys.inject(inputs, :fetch) << f_hsh
#   end
# end
#
# def select_hsh(f,v)
#   {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: v}
# end
#
# def set_hsh(f,set=[])
#   {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: set}
# end
#
# def store_hsh(f,k,v)
#   {render_as: render_as(f), label: f.field_name, method: k, selected: v}
# end
#
# def render_as(f)
#   f.type.underscore
# end
#
# def fk_id(word)
#   [word.singularize, 'id'].join("_")
# end
#
# def name_method(f)
#   if render_types.include?(f.type.underscore)
#     fk_id(f.kind)
#   else
#     delim_format(words: f.field_name, join_delim: '_', split_delims: [' ', '-'])
#   end
# end

# def fieldables
#   item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
#   # set = item_groups.where(base_type: 'FieldItem').order(:sort) #.map(&:target)
#   # set.includes(:target).map(&:target)
# end

##############################################################################

# def nested_fieldables(h={})
#   grouped_fieldables.each do |kind, targets|
#     h.merge!( { kind => format_nested(targets) } )
#   end
#   h
# end
#
# def grouped_fieldables
#   fieldables.group_by{|f| f.kind}
# end
#
# def format_nested(targets, set=[])
#   #puts "targets: #{targets}, targets.one? #{targets.one?} targets.first.class: #{targets.first.class}"
#   return targets.first if targets.one? && targets.first.class != FieldSet
#   targets.each do |f|
#
#     if f.class == FieldSet
#       set << f.fieldables
#     else
#       set << f
#     end
#
#   end
#   set.flatten
# end
#
# def nested_ffieldables(f, kind)
#  kind ? f : {f.kind => f}
# end
