class Item < ApplicationRecord

  include STI
  include ExportAttrs
  include SkuRange

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :standard_products, through: :item_groups, source: :target, source_type: "StandardProduct"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

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
    #order_search(input_group, sort_keys, hstore)
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
  #attr_options
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

  # Item.find(6).product_group['params']   Item.find(6).product_group['inputs']
  # Item.find(5).field_targets ## pg = Item.find(5).product_group['params'] ## h['inputs'] ## h['inputs']['field_sets']   Item.find(5).product_group['inputs']['field_sets']
  # product_group ############################################################## Item.find(5).product_group['inputs']['field_sets']
  def product_group
    params, inputs = {}, {'options'=>[], 'field_sets'=>{}}
    return {'params'=>params, 'inputs'=>inputs, 'description'=> 'Pending'} if !product
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
    #{'params'=>params, 'inputs'=>inputs, 'description' => description_hsh(params['options'], params['field_sets'])}
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
      elsif f.type == 'FieldSet'
        field_set_group(f, i_fields, params, inputs, opt_scope)
      elsif f.type != 'FieldSet'
        puts "testing!!! #{f.field_name}"
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
  # def description_hsh(opt_params, fs_params, hsh={})
  #   item_hsh(hsh)
  #   media_hsh(opt_params.select{|k,v| !v.nil?}, hsh)
  #   sub_media_hsh(fs_params, hsh)
  #   dimension_hsh(hsh, hsh.keys)
  #
  #   description_builder(hsh, {'title' => title_keys(hsh, hsh.keys), 'body' => body_keys(hsh, hsh.keys)})
  # end

  # item_hsh: PART I ###########################################################

  # def item_hsh(hsh)
  #   set_artist(hsh)
  #   #set_title(hsh)
  # end
  #
  # def set_artist(hsh)
  #   hsh.merge!(field_name_value('artist', artist.artist_name)) if artist
  # end

  # def set_title(hsh)
  #   v = title.blank? ? 'This' : "\"#{title}\""
  #   hsh.merge!(field_name_value('title', v))
  # end

  # media_hsh: PART II #########################################################

  # def media_hsh(source_hsh, hsh)
  #   %w[embellished category sub_category medium material].each do |kind|
  #     merge_media_to_hsh(source_hsh, hsh, kind)
  #   end
  #   hsh
  # end
  #
  # def merge_media_to_hsh(source_hsh, hsh, kind)
  #   if source_hsh.has_key?(kind+'_id')
  #     f_hsh_from_source_hsh(source_hsh, hsh, kind)
  #   elsif product.tags.has_key?(kind) && product.tags[kind] != 'n/a'
  #     f_hsh_from_from_product_hsh(hsh, kind)
  #   end
  # end
  #
  # # sub_media_hsh: PART III ####################################################
  #
  # def sub_media_hsh(source_hsh, hsh)
  #   source_hsh.each do |kind, kind_hsh|
  #     merge_options_and_tags_hsh(kind_hsh, hsh, kind)
  #   end
  #   hsh
  # end
  #
  # def merge_options_and_tags_hsh(kind_hsh, hsh, kind)
  #   %w[options tags].each do |f_key|
  #     next if !kind_hsh.dig(f_key) || kind_hsh.dig(f_key).values.any?{|v| v.blank?}
  #     f_hsh_from_source_hsh(kind_hsh.dig(f_key), hsh, kind) if f_key == 'options'
  #     tags_hsh(kind_hsh.dig(f_key), hsh, kind, 'tags') if f_key == 'tags'
  #   end
  #   hsh
  # end
  #
  # def f_hsh_from_source_hsh(source_hsh, hsh, k)
  #   hsh.merge!(field_name_value(k, source_hsh[fk_id(k)].field_name))
  # end
  #
  # def f_hsh_from_from_product_hsh(hsh, k)
  #   hsh.merge!(field_name_value(k, product.tags[k].underscore.split('_').join(' ')))
  # end
  #
  # def tags_hsh(tags_hsh, hsh, *keys)
  #   if hsh.has_key?(keys[0])
  #     hsh[keys[0]][keys[1]] = tags_hsh
  #   else
  #     hsh[keys[0]] = {keys[1] => tags_hsh}
  #   end
  # end
  #
  # def field_name_value(k,v)
  #   {k=>{'field_name'=>v}}
  # end
  #
  # # dimension_hsh methods ######################################################
  #
  # def dimension_hsh(d_hsh, d_keys, tag_set=[])
  #   %w[mounting dimension].each do |k|
  #     if d_keys.include?(k) && d_hsh.dig(k, 'tags')
  #       k_tags, tag_keys_split = d_hsh[k]['tags'], d_hsh.dig(k, 'tags').keys.map{|tag_key| tag_key.split('_')}.flatten
  #       tag_set << [format_dimensions(k_tags), format_dimension_type(d_hsh[k], tag_keys_split)].join(' ')
  #     end
  #   end
  #   punct = tag_set.count > 1 ? ', ' : ' '
  #   d_hsh['dimension']['tags']['body'] = "Measures approx. #{tag_set.join(punct)}." unless tag_set.empty?
  # end
  #
  # def format_dimension_type(kind_hsh, tag_keys_split)
  #   if tag_keys_split[0] == 'material'
  #     material_dimension(tag_keys_split)
  #   elsif tag_keys_split[0] == 'mounting'
  #     mounting_dimension(kind_hsh['field_name'])
  #   end
  # end
  #
  # def format_dimensions(tags)
  #   tags.transform_values{|v| v+"\""}.values.join(' x ')
  # end
  #
  # def mounting_dimension(field_name)
  #   case
  #     when field_name == 'framed'; "(frame)"
  #     when field_name == 'matted'; "(matting)"
  #     when field_name == 'border'; "(border)"
  #   end
  # end
  #
  # def material_dimension(tags_keys_split)
  #   tags_keys_split.include?('image-diameter') ? "(image-diameter)" : "(image)"
  # end
  #
  # #refactored methods for building description #################################
  #
  # def description_builder(d_hsh, d_keys_hsh, hsh={})
  #   d_keys_hsh.each do |context, d_keys|
  #     build_description_by_kind(d_hsh, context, d_keys, hsh.merge!({context =>[]}))
  #     hsh[context] = format_description_by_context(hsh[context].compact, context)
  #   end
  #   hsh
  # end
  #
  # def build_description_by_kind(d_hsh, context, d_keys, hsh)
  #   d_keys.each do |k|
  #     hsh[context] << description_cases(d_hsh, context, k, d_hsh[k]['field_name'], d_hsh[k]['tags'], d_keys)
  #   end
  #   hsh[context].compact
  # end
  #
  # def format_description_by_context(word_set, context)
  #   word_set.map!{|words| cap_words(words)} if context == 'title'
  #   word_set.join(' ')
  # end
  #
  # def description_cases(d_hsh, context, k, field_name, tags, d_keys)
  #   case
  #     when k == 'artist' then format_artist(context, field_name)
  #     when k == 'title' && context == 'body' && d_keys.index('title')+1 then format_title(d_hsh[d_keys[d_keys.index('title')+1]]['field_name'], field_name)
  #     when k == 'mounting' then format_mounting(context, field_name)
  #     when k == 'category' && field_name == 'one of a kind' then format_category(context)
  #     when k == 'medium' && context == 'title' then format_medium(d_keys, field_name)
  #     when k == 'material' then format_material(context, d_keys, field_name, field_name.split(' '))
  #     when k == 'leafing' then format_leafing(d_keys, field_name)
  #     when k == 'remarque' then format_remarque(context, d_keys, field_name)
  #     when k == 'numbering' then format_numbering(d_keys, field_name, tags, field_name.split(' ').include?('from'))
  #     when k == 'signature' then format_signature(context, d_keys, field_name)
  #     when k == 'certificate' then format_certificate(context, field_name)
  #     when k == 'dimension' then format_dimension(context, tags)
  #     else field_name
  #   end
  # end
  #
  # # description_cases methods for building description #########################
  #
  # def format_artist(context, field_name)
  #   context == 'title' ? "#{field_name}," : "by #{field_name},"
  # end
  #
  # def format_title(word, field_name)
  #   "#{field_name} is #{format_vowel(word, ['one-of-a-kind', 'unique'])}"
  # end
  #
  # def format_mounting(context, field_name)
  #   if context == 'title' && field_name.split(' ').include?('framed')
  #     'framed'
  #   elsif context == 'body' && field_name.split(' ').any?{|i| ['framed', 'matted']}
  #     "This piece comes #{field_name}."
  #   end
  # end
  #
  # def format_medium(d_keys, field_name)
  #    %w[material leafing remarque].all? {|k| d_keys.exclude?(k)} ? "#{field_name}," : field_name
  # end
  #
  # def format_category(context)
  #   context == 'title' ? 'One-of-a-Kind' : 'one-of-a-kind'
  # end
  #
  # def format_material(context, d_keys, field_name, split_field_name)
  #   return if context == 'title' && split_field_name.include?('paper')
  #   field_name = 'canvas' if context == 'title' && split_field_name.include?('stretched')
  #   field_name = 'canvas' if context == 'body' && split_field_name.include?('gallery')
  #   punct = ',' if %w[leafing remarque].all? {|i| d_keys.exclude?(i)} && context == 'title'
  #   "on #{[field_name, punct].join('')}"
  # end
  #
  # def format_leafing(d_keys, field_name)
  #   punct = ',' if d_keys.exclude?('remarque')
  #   "with #{[field_name, punct].join('')}"
  # end
  #
  # def format_remarque(context, d_keys, field_name)
  #   word = d_keys.include?('leafing') ? 'and' : 'with'
  #   field_name = field_name+',' #if context == 'title'
  #   "#{word} #{field_name}"
  # end
  #
  # def format_numbering(d_keys, field_name, tags, proof_ed)
  #   if proof_ed && d_keys.include?('material')
  #     field_name
  #   elsif proof_ed && %w[leafing remarque].all? {|k| d_keys.exclude?(k)}
  #     "#{field_name},"
  #   elsif !proof_ed
  #     word = 'and' if d_keys.include?('signature')
  #     words = tags ? "#{field_name} #{tags.values.join('/')}" : field_name
  #     [words, word].join(' ')
  #   end
  # end
  #
  # def format_signature(context, d_keys, field_name)
  #   context == 'title' ? title_signature(d_keys, field_name) : body_signature(d_keys, field_name)
  #   # if context == 'title' && d_keys.include?('certificate')
  #   #   field_name
  #   # elsif context == 'title' && d_keys.exclude?('certificate')
  #   #   "#{field_name}."
  #   # elsif context == 'body'
  #   #   "#{field_name} by the artist."
  #   # end
  # end
  #
  # def title_signature(d_keys, field_name)
  #   field_name = field_name.split(' ').include?('authorized') ? 'signed' : field_name
  #   punct = '.' if d_keys.exclude?('certificate')
  #   [field_name, punct].join('')
  # end
  #
  # def body_signature(d_keys, field_name)
  #   if k = %w[plate authorized].detect{|k| field_name.split(' ').include?(k)}
  #     "bearing the #{k} signature of the artist."
  #   elsif field_name.split(' ').include?('estate')
  #     "#{field_name}."
  #   else
  #     "#{field_name} by the artist."
  #   end
  # end
  #
  # def format_certificate(context, field_name)
  #   field_name = field_name == 'LOA' ? 'Letter' : 'Certificate'
  #   word = context == 'title' ? 'with' : 'Includes'
  #   [word, field_name, 'of Authenticity.'].join(' ')
  # end
  #
  # def format_dimension(context, tags)
  #   tags['body'] if context == 'body'
  # end
  #
  # # title_keys #################################################################
  #
  # def title_keys(d_hsh, d_keys)
  #   reorder_title_keys(d_hsh, all_title_keys).reject {|k| reject_title_keys(d_hsh, d_keys, k)}
  # end
  #
  # def reorder_title_keys(d_hsh, title_keys)
  #   all_title_keys.each do |k|
  #     reorder_title_key_cases(k, d_hsh[k]['field_name'], title_keys) if d_hsh.has_key?(k)
  #   end
  #   title_keys
  # end
  #
  # def reorder_title_key_cases(k, v, title_keys)
  #   if k == 'numbering' && v.split(' ')[0] == 'from'
  #     title_keys.delete(k)
  #     title_keys.insert(title_keys.index('material'), k)
  #   else
  #     title_keys
  #   end
  # end
  #
  # def reject_title_keys(d_hsh, d_keys, k)
  #   return true if d_keys.exclude?(k)
  #   reject_title_keys_cases(d_hsh, d_keys, k, d_hsh[k]['field_name'])
  # end
  #
  # def reject_title_keys_cases(d_hsh, d_keys, k, v)
  #   case
  #     when k == 'medium' && v.split(' ').include?('giclee') && d_hsh['material']['field_name'].split(' ').exclude?('paper'); true
  #     when k == 'material' && v.split(' ').include?('paper'); true
  #     when k == 'title' && v[0] != "\""; true
  #     else false
  #   end
  # end
  #
  # # def export_keys
  # #   %w[sku artist artist_id title tag_line property_room description retail qty art_category art_type medium material width height frame_width frame_height]
  # # end
  #
  # def export_keys
  #   %w[sku artist tag_line medium material width]
  # end
  #
  # def all_title_keys
  #   %w[artist title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate]
  # end
  #
  # # body_keys ##################################################################
  #
  # def body_keys(d_hsh, d_keys)
  #   reorder_title_keys(d_hsh, all_body_keys).reject {|k| reject_body_keys(d_hsh, d_keys, k)}
  # end
  #
  # def reject_body_keys(d_hsh, d_keys, k)
  #   d_keys.exclude?(k)
  # end
  #
  # def all_body_keys
  #   %w[title embellished category sub_category medium material leafing remarque artist numbering signature mounting certificate dimension]
  # end

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
