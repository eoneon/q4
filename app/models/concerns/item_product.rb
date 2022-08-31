require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern

  def form_and_data(action:nil)
    p = product
    return [[], {}] if !p
    input_group = item_product_attrs(p.tags, init_input_group(fieldables))
    config_group(fields: p.unpacked_fields, input_group: input_group)

    # config_form_group(input_group, p.tags)
    # return input_group[:rows] if action == 'show'
    finish_config_group(input_group, input_group[:context], input_group[:d_hsh])
    description_hsh(key_group, input_group[:context], input_group[:d_hsh], input_group[:attrs])
    [input_group[:rows], input_group[:attrs]]
  end

  ##############################################################################

  def config_group(fields:nil, input_group:nil)
  	config_loop(fields: fields, input_group: input_group)
    config_dimensions(input_group, input_group[:context], input_group[:d_hsh])
  end

  def config_loop(fields:nil, input_group:nil)
    fields.each_with_object(input_group) do |f, input_group|
      tb_tags_from_field(input_group[:d_hsh], f, f.kind.underscore)
      description_field_case(*f.fattrs, f, input_group)
    end
  end

  def description_field_case(k, t, f_name, f, input_group)
  	if field_set?(t)
  		config_loop(fields: f.fieldables, input_group: input_group)
  	elsif !no_assocs?(t)
  		push_input_and_config_selected(k, t, f_name, f, input_group)
    elsif tags_hsh = f.tags
      field_context_order(k, tags_hsh, input_group[:context])
  	end
  end

  def push_input_and_config_selected(k, t, f_name, f, input_group)
  	input_group[:inputs] << f_hsh(k, t, f_name, f)
  	if selected = input_group[:param_hsh].dig(k, t_type(t), f_name)
  		input_group[:inputs][-1][:selected] = format_selected(t, selected)
      context_from_selected(k, t, f_name, selected, input_group[:context])
  		tag_attr?(t) ? selected_tag_attr(input_group[:d_hsh], selected, k, f_name) : selected_field(input_group, selected, *selected.fattrs)
  	end
  end

  def selected_tag_attr(d_hsh, selected, k, f_name)
    if k=='dimension'
      Dimension.measurement_hsh(d_hsh, selected, k, f_name)
    else
      Item.case_merge(d_hsh, selected, k, f_name)
    end
  end

  def selected_field(input_group, selected, k, t, f_name)
  	tags_from_selected_field(input_group[:d_hsh], input_group[:context], selected, k, t, f_name) if selected.tags
  	config_loop(fields: selected.fieldables, input_group: input_group) if field_set?(t)
  end

  def tags_from_selected_field(d_hsh, context, selected, k, t, f_name)
    related_field_params(d_hsh, selected, k, t, f_name) if Dimension.related_kinds.include?(k)
    tb_tags_from_field(d_hsh, selected, k) unless k=='dimension'
  end

  def tb_tags_from_field(d_hsh, f, k)
    (%w[material_mounting mounting_search] + tb_keys).map {|tag_key| Item.case_merge(d_hsh, f.tags[tag_key], k, tag_key)} if f.tags
  end

  def related_field_params(d_hsh, f, k, t, f_name)
    f.tags.select{|k,v| Dimension.tags.include?(k) && v != 'n/a'}.each do |tag_key, tag_val|
      Item.case_merge(d_hsh, tag_val, 'dimension', tag_key, 'tag')
    end
  end

  def format_selected(t, selected)
    tag_attr?(t) ? selected : selected.id
  end

  #utiltiy-ish##################################################################
  def item_product_attrs(p_tags, input_group)
  	d_hsh, context, attrs = [:d_hsh, :context, :attrs].map{|k| input_group[k]}
  	config_attrs(p_tags, attrs)
  	artist_params(context, attrs, d_hsh)
  	title_params(context, attrs, d_hsh)
    input_group
  end

  def config_attrs(p_tags, attrs)
  	init_attrs(attrs).merge!(default_hsh(*contexts[:csv][:export]))
  	%w[sku retail qty].map{|k| attrs[k] = public_send(k)}
  	Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
  end
  ##############################################################################
  def init_input_group(fields, input_group={:param_hsh=>{}, :d_hsh=>{}, :context=>{}, :inputs=>[], :attrs=>{}})
    tags.each_with_object (input_group) {|(key, selected), hsh| Item.case_merge(input_group, (tag_attr?(key.split('::')[1]) ? selected : fields.detect{|f| f.id==(selected.to_i)}), :param_hsh, *key.split('::'))}
  end

  def init_attrs(attrs)
    attrs.merge!(default_hsh(*contexts[:csv][:export]))
  end

  ##############################################################################
  ##############################################################################

  def artist_params(context, attrs, d_hsh, k='artist')
    return unless artist
    d_hsh.merge!({k=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
    field_context_order(k, d_hsh[k], context)
  end

  def title_params(context, attrs, d_hsh, k='title')
  	config_title_value(context, d_hsh, k)
  	attrs[k] = attrs_title
  end

  def config_title_value(context, d_hsh, k)
  	admin_tb_keys.each do |tag_key|
  		if v = public_send("#{tag_key}_#{k}")
  			Item.case_merge(d_hsh, v, k, tag_key)
        set_order(context, tag_key.to_sym, k)
  		end
  	end
  end

  def config_dimensions(input_group, context, d_hsh, k='dimension')
  	if dimension_hsh = hsh_slice_and_delete(d_hsh, k)
      Dimension.config_dimension(k, dimension_hsh, input_group, context, d_hsh)
      field_context_order(k, d_hsh[k], context)
  	end
  end

  ##############################################################################
  ##############################################################################

  def finish_config_group(input_group, context, d_hsh)
    set_compound_keys(context)
    config_dependent_kinds(input_group, context, d_hsh)
  end

  def config_dependent_kinds(input_group, context, d_hsh)
    dependent_kinds_hsh(context[:body][:order].keys).each do |klass, kinds|
      kinds.each do |k|
        #config_public_kind(k, klass, d_hsh[k], k_hsh, input_group, context)
        config_public_kind(k, klass, d_hsh[k], d_hsh[k].slice!(*tb_keys), input_group, context)
      end
    end
  end

  def config_public_kind(k, klass, tb_hsh, k_hsh, input_group, context)
  	to_class(klass).public_send("config_#{k}", k, tb_hsh, k_hsh, input_group, context)
  end

  ##############################################################################
  # gartner_blade_params ####################################################### GartnerBlade
  def gartner_blade_params(keys, context, d_hsh, attrs, store)
    gb_hsh = slice_vals_and_delete(d_hsh, keys)
    unrelated_params(context, gb_hsh, store)
    title_hsh = slice_vals_and_delete(store, %w[size color sculpture_type lid])
    title = title_hsh.inject([]) {|a,(k,v_hsh)| a << v_hsh['tagline']}.join(' ')
    GartnerBlade.new.build_gartner_blade(keys, title, context, attrs, store)
  end

  ##############################################################################
  # input_params
  ##############################################################################
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

  # utility methods ############################################################ #symbolize: move to textable, tb_keys: remove
  def symbolize(w)
    w.downcase.split(' ').join('_').to_sym
  end

  def tb_keys
    %w[tagline invoice_tagline search_tagline body]
  end

  def admin_tb_keys
    tb_keys.values_at(0,-1)
  end

  def all_title_keys
    tb_keys[0..2]
  end

  ##############################################################################

  def config_form_group(input_group, tags)
    input_group[:context][product_category(tags['product_type'])] = true
    input_group[:rows] = build_form_rows(input_group[:inputs].group_by{|h| h[:k]}, media_group(input_group[:context]).merge!(form_groups))
  end

  def media_group(context)
    case
      when context[:flat_art]; {'media'=> {header: %w[category embellishing medium], body: %w[leafing remarque]}}
      when context[:sculpture_art]; {'media'=> {header: %w[category embellishing medium sculpture_type], body: %w[]}}
      when context[:gartner_blade]; {'media'=> {header: %w[sculpture_type sculpture_part], body: %w[]}}
    end
  end

  def form_groups
    {
      'numbering'=> {header: %w[numbering], body: %w[]},
      'material_mounting'=> {header: %w[material mounting], body: %w[]},
      'authentication'=> {header: %w[seal signature certificate], body: %w[dated verification]},
      'dimension'=> {header: %w[dimension], body: %w[]},
      'disclaimer'=> {header: %w[disclaimer], body: %w[]}
    }
  end

  def build_form_rows(form_hsh, form_group)
    form_group.each_with_object({}) do |(card_id,card), hsh|
      if card[:header].any?{|k| form_hsh[k]}
        Item.case_merge(hsh, build_row(card[:header], form_hsh), card_id, :header)
        Item.case_merge(hsh, build_row(card[:body], form_hsh), card_id, :body)
      end
    end
  end

  def build_row(keys,hsh)
    row = keys.select{|k| hsh.has_key?(k)}.each_with_object([]){|k,div_row| div_row << hsh[k]}.flatten
    row = row.each_with_index {|f_hsh,i| f_hsh[:i] = i}
    row
  end
end

# THE END ######################################################################
# def config_loop(fields:nil, input_group:nil)
# 	(fields ? fields : product.unpacked_fields).each_with_object(input_group ? input_group : init_input_group(fieldables)) do |f, input_group|
#     k, t, f_name = f.fattrs
#     tb_tags_from_field(input_group[:d_hsh], f, k)
# 		if field_set?(t)
# 			config_loop(fields: f.fieldables, input_group: input_group)
# 		elsif !no_assocs?(t)
# 			push_input_and_config_selected(k, t, f_name, f, input_group)
#     elsif no_assocs?(t)
#       input_group[:context][k.to_sym] = true if contexts[:present_keys].include?(k)
# 		end
# 	end
# end

# def config_prev_kind(prevk, k, kset, input_group, context, d_hsh)
#   kset << k if prevk != k
#   if kset.count>1 && prevk != k
#     config_compound_kind(k, input_group, context, d_hsh)
#   end
# end

# def form_and_data(action:nil, f_grp:{context: {reorder:[], remove:[]}, attrs:{}, store:{}})
#   p = product
#   return [[], {}] if !p
#   p.product_attrs(f_grp)
#   #f_grp[:param_hsh] = config_params(fieldables)
#   f_grp.merge!(get_inputs_and_tag_hsh(fields: p.unpacked_fields))
#   f_grp[:rows] = build_form_rows(f_grp[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
#   f_grp[:d_hsh] = f_grp[:tag_hsh]
#   return f_grp[:rows] if action == 'show'
#   related_and_divergent_params(f_grp)
#   [f_grp[:rows], f_grp[:attrs]]
# end

##############################################################################


##############################################################################
# def product_attrs(p_tags, f_grp)
#   f_grp[:context][product_category(p_tags['product_type'])] = true
#   Medium.tag_keys.map{|k| f_grp[:attrs][k] = tags[k]}
# end

# def item_attrs(f_grp)
#   %w[sku retail qty].map{|k| f_grp[:attrs][k] = public_send(k)}
#   artist_params(f_grp[:context], f_grp[:attrs], f_grp[:store])
#   merge_title_params(f_grp[:attrs], f_grp[:store], tagline_title, body_title, attrs_title) unless f_grp[:context][:gartner_blade]
# end

# def related_and_divergent_params(f_grp)
#   item_attrs(f_grp[:context], f_grp[:attrs], f_grp[:store])
#   f_grp[:attrs].merge!(default_hsh('width', 'height', 'frame_width', 'frame_height'))
#   related_params(f_grp)
#   shared_context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
#   divergent_params(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store]) if f_grp[:context][:valid]
# end

##############################################################################
# related_params II: material, mounting, dimension: see Dimension.rb
##############################################################################
# def related_params(f_grp)
#   contexts[:related_args].each do |args|
#     puts "args=>  #{args}"
#     if k_hsh = slice_and_delete(f_grp[:d_hsh], args[:k])
#       puts "k_hsh=> #{k_hsh}, d_hsh=> #{f_grp[:d_hsh]}"
#       Dimension.new.material_mounting_dimension_params(k_hsh, f_grp, args)
#     end
#   end
# end
##############################################################################
# shared_context_and_attrs
##############################################################################
# def shared_context_and_attrs(context, d_hsh, attrs, store, p_tags)
#   d_hsh.keys.map{|k| context[k.to_sym] = true if contexts[:present_keys].include?(k)}
#   d_hsh.select{|k,h| h['tagline']}.each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
#   #flatten_context(d_hsh).each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
#   context[:valid] = true if context[:medium] || context[:sculpture_type]
#   context[:missing] = true if context[:unsigned] && !context[:disclaimer]
# end

##############################################################################
# divergent_params
##############################################################################
# def divergent_params(context, d_hsh, attrs, store)
#   if context[:gartner_blade]
#     gartner_blade_params(contexts[:gartner_blade], context, d_hsh, attrs, store)
#   else
#     standard_params(context, d_hsh, attrs, store)
#   end
# end

# def config_form_group(input_group, tags, f_grp)
#   f_grp[:context][product_category(tags['product_type'])] = true
#   f_grp[:rows] = build_form_rows(input_group[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
#   #f_grp[:rows] = build_form_rows(hsh_slice_and_delete(input_group[:inputs]).group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
# end

# def compound_keys(context, keys)
#   context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
# end

# def form_and_data(action:nil, f_grp:{context: {reorder:[], remove:[]}, attrs:{}, store:{}})
# 	return [[], {}] if !product
# 	product.config_form_group(f_grp, i_args)
# 	return f_grp[:rows] if action == 'show'
#   related_and_divergent_params(f_grp)
#   a,b = f_grp[:rows], f_grp[:attrs]
# end

# i = Item.find(97)   h = Item.find(183).input_group
# def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
#   return [f_grp[:rows], f_grp[:attrs] ] if !product
#   product.product_item_loop(input_params, f_grp, keys=%w[tagline invoice_tagline tagline_search body material_dimension mounting_dimension material_mounting mounting_search])
#   #puts "2f_grp[:rows] = #{f_grp[:rows]}"
#   related_and_divergent_params(f_grp)
#   a,b = f_grp[:rows], f_grp[:attrs]
# end
# ### reorder_remove
# def reorder_remove(context)
#   reorder_rules(context)
#   remove_rules(context)
# end

# def reorder_rules(context)
#   context[:reorder] << {k:'numbering', ref: 'medium', i: 1} if context[:proof_edition]
#   context[:reorder] << {k:'embellishing', ref: 'medium'} if context[:embellishing_category] && !context[:proof_edition] && !context[:numbered]
#   if h = reorder_signature(context)
#     context[:reorder] << h.merge!({k: 'signature'})
#   end
# end
#
# def reorder_signature(context)
#   if context[:missing]
#     {i: -1}
#   elsif !context[:category]
#     {ref: 'medium'} if context[:signature] && !context[:certificate]
#   elsif context[:proof_edition] && !context[:certificate]
#     !context[:embellishing] ? {ref: 'category'} : {ref: 'embellishing'}
#   elsif context[:signature] && (!context[:numbered] && !context[:certificate])
#     {ref: 'medium'}
#   end
# end

# def remove_rules(context)
#   context[:remove] << 'material' if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
#   context[:remove] << 'medium' if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
# end

### artist
# def artist_params(context, attrs, store)
#   return unless artist
#   context['artist'] = true
#   store.merge!({'artist'=> artist.artist_params['d_hsh']})
#   attrs.merge!(artist.artist_params['attrs'])
# end

### title
# def merge_title_params(attrs, store, tagline_title, body_title, attrs_title, k='title', key='tagline', key2='body')
#   store.merge!({k=> {key=> tagline_title, key2=> body_title}})
#   attrs.merge!({k=> attrs_title})
# end

# utility
# def flatten_context(hsh, key='tagline')
#   hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}
# end

##############################################################################
# unrelated_params: see Description.rb
##############################################################################

##############################################################################
# build_description
##############################################################################
# def flat_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
#   hsh['tagline'] = build_tagline(context, store)
#   hsh['description'] = build_body(context, store)
#   hsh['invoice_tagline'] = build_invoice_tagline(context, store)
#   hsh['property_room'] = build_property_room(context, store)
#   hsh['search_tagline'] = build_search_tagline(context, store)
#   hsh
# end
#
# # tagline
# def build_tagline(context, store)
#   tagline = update_tagline(context, store, valid_description_keys(store, contexts[:tagline][:keys], 'tagline'))
#   tagline_punct(context, tagline, tagline.keys)
# end

# build_invoice_tagline
# def build_invoice_tagline(context, store)
#   invoice_hsh = filtered_params(store, contexts[:invoice_tagline][:keys], 'invoice_tagline', 'tagline')
#   invoice_tagline = update_invoice_tagline(context, invoice_hsh.keys, invoice_hsh)
#   invoice_tagline = tagline_punct(context, invoice_tagline, invoice_tagline.keys)
#   Item.char_limit(invoice_tagline, contexts[:invoice_tagline][:set], 140)
# end

# def build_property_room(context, store)
#   invoice_hsh = filtered_params(store, contexts[:property_room][:keys], 'property_room', 'tagline')
#   property_room = update_invoice_tagline(context, invoice_hsh.keys, invoice_hsh)
#   property_room = tagline_punct(context, property_room, property_room.keys)
#   Item.char_limit(property_room, contexts[:property_room][:set], 128)
# end
#
# def build_search_tagline(context, store)
#   search_hsh = filtered_params(store, contexts[:search_tagline][:keys], 'search_tagline', 'tagline')
#   search_tagline = update_invoice_tagline(context, search_hsh.keys, search_hsh)
#   search_tagline = tagline_punct(context, search_tagline, search_tagline.keys)
#   Item.char_limit(search_tagline, contexts[:search_tagline][:set], 115)
# end
#
# def update_invoice_tagline(context, keys, invoice_hsh)
#   keys = context[:reorder].each_with_object(keys) {|h| reorder_keys(h.merge!({keys: keys}))}
#   keys.each_with_object({}){|k,h| h[k] = invoice_hsh[k]}
# end

# description
# def build_body(context, store)
#   keys = valid_description_keys(store, contexts[:body][:keys], 'body')
#   reorder_keys(keys: keys, k: 'numbering', ref: 'medium', i:1) if context[:proof_edition]
#   body = description_params(store, keys, 'body')
#   join_title(body, keys[keys.index('title')+1])
#   body_punct(context, body, body.keys)
# end

# key-array methods ########################################################## valid_description_keys: duplicate?
# def valid_description_keys(store, keys, tag_key)
#   keys.select{|k| store.dig(k,tag_key).present?}
# end
# 84, 297, 304: replace with: filtered_hsh(h:, keys:[], dig_set:[])
# def description_params(store, keys, tag_key)
#   keys.each_with_object({}) do |k,h|
#     h[k] = store.dig(k,tag_key) if store.dig(k,tag_key)
#   end
# end

# def filtered_params(hsh, keys, *dig_opts)
#   keys.each_with_object({}) do |k,h|
#     if tag_key = dig_opts.detect{|tag_key| hsh.dig(k,tag_key)}
#       if v = hsh.dig(k,tag_key)
#         h[k] = v
#       end
#     end
#   end
# end

# def valid_description_params(store, keys, tag_key)
#   keys.each_with_object({}) do |k,h|
#     h[k] = store.dig(k,tag_key) if store.dig(k,tag_key)
#   end
# end
