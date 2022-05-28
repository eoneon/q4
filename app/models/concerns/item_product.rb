require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern

  def form_and_data(action:nil, f_grp:{context: {reorder:[], remove:[]}, attrs:{}, store:{}})
  	return [[], {}] if !product
    product.config_form_group(f_grp.merge!(inputs_and_tag_hsh(input_group: param_group)))
  	return f_grp[:rows] if action == 'show'
  	related_and_divergent_params(f_grp)
  	[f_grp[:rows], f_grp[:attrs]]
  end

  def item_attrs(context, attrs, store)
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
    artist_params(attrs, store)
    merge_title_params(attrs, store, tagline_title, body_title, attrs_title) unless context[:gartner_blade]
  end

  def related_and_divergent_params(f_grp)
    item_attrs(f_grp[:context], f_grp[:attrs], f_grp[:store])
    f_grp[:attrs].merge!(defualt_hsh('width', 'height', 'frame_width', 'frame_height'))
    related_params(f_grp)
    shared_context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
    divergent_params(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store]) if f_grp[:context][:valid]
  end

  ##############################################################################
  # related_params II: material, mounting, dimension: see Dimension.rb
  ##############################################################################
  def related_params(f_grp)
    contexts[:related_args].each do |args|
      if k_hsh = slice_and_delete(f_grp[:d_hsh], args[:k])
        Dimension.new.material_mounting_dimension_params(k_hsh, f_grp, args)
      end
    end
  end

  ##############################################################################
  # shared_context_and_attrs
  ##############################################################################
  def shared_context_and_attrs(context, d_hsh, attrs, store, p_tags)
    d_hsh.keys.map{|k| context[k.to_sym] = true if contexts[:present_keys].include?(k)}
    flatten_context(d_hsh).each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
    context[:valid] = true if context[:medium] || context[:sculpture_type]
    context[:missing] = true if context[:unsigned] && !context[:disclaimer]
  end

  ##############################################################################
  # divergent_params
  ##############################################################################
  def divergent_params(context, d_hsh, attrs, store)
    if context[:gartner_blade]
      gartner_blade_params(contexts[:gartner_blade], context, d_hsh, attrs, store)
    else
      standard_params(context, d_hsh, attrs, store)
    end
  end

  # gartner_blade_params ####################################################### GartnerBlade
  def gartner_blade_params(keys, context, d_hsh, attrs, store)
    gb_hsh = slice_vals_and_delete(d_hsh, keys)
    unrelated_params(context, gb_hsh, store)
    title_hsh = slice_vals_and_delete(store, %w[size color sculpture_type lid])
    title = title_hsh.inject([]) {|a,(k,v_hsh)| a << v_hsh['tagline']}.join(' ')
    GartnerBlade.new.build_gartner_blade(keys, title, context, attrs, store)
  end

  # standard_params ################################################################
  def standard_params(context, d_hsh, attrs, store)
    standard_context(context, d_hsh, store)
    unrelated_params(context, d_hsh, store)
    search_edition(d_hsh, attrs)
    attrs.merge!(flat_description(context, store))
  end

  ## standard_context
  def standard_context(context, d_hsh, store)
    related_context(store, context)
    nested_params_context(context, d_hsh)
    contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
    reorder_remove(context)
  end

  def related_context(store, context)
    description_params(store, %w[dimension material mounting], 'tagline').each do |k,v|
      if k == 'dimension'
        context[k.to_sym] = true
      elsif i = ['Framed', 'Gallery Wrapped', 'Rice', 'Paper'].detect{|i| v.index(i)}
        context[symbolize(i)] = true
      end
    end
  end

  def unrelated_context(context, k, v, tagline_vals)
    if set = tagline_vals.detect{|set| v.index(set[0])}
      context[symbolize(set[-1])] = true
    end
  end

  ### nested: proof_edition, animator_seal & sports_seal
  def nested_params_context(context, d_hsh)
    context[(d_hsh['numbering']['tagline'].has_key?('proof_edition') ? :proof_edition : :numbered)] = true if d_hsh['numbering']
    %w[animator_seal sports_seal].map{|k| context[k.to_sym] = true if d_hsh['seal']['body'].has_key?(k)} if d_hsh['seal']
  end

  def search_edition(d_hsh, attrs)
    if ed_val = d_hsh.dig("numbering", "tagline")
      attrs.merge!({'edition'=>ed_val.values[0].split(' ')[0].sub('Numbered', 'No')})
    end
  end

  ### reorder_remove
  def reorder_remove(context)
    reorder_rules(context)
    remove_rules(context)
  end

  def reorder_rules(context)
    context[:reorder] << {k:'numbering', ref: 'medium', i: 1} if context[:proof_edition]
    context[:reorder] << {k:'embellishing', ref: 'medium'} if context[:embellishing_category] && !context[:proof_edition] && !context[:numbered]
    if h = reorder_signature(context)
      context[:reorder] << h.merge!({k: 'signature'})
    end
  end

  def reorder_signature(context)
    if context[:missing]
      {i: -1}
    elsif !context[:category]
      {ref: 'medium'} if context[:signature] && !context[:certificate]
    elsif context[:proof_edition] && !context[:certificate]
      !context[:embellishing] ? {ref: 'category'} : {ref: 'embellishing'}
    elsif context[:signature] && (!context[:numbered] && !context[:certificate])
      {ref: 'medium'}
    end
  end

  def remove_rules(context)
    context[:remove] << 'material' if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
    context[:remove] << 'medium' if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
  end

  ### artist
  def artist_params(attrs, store)
    return unless artist
    store.merge!({'artist'=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
  end

  ### title
  def merge_title_params(attrs, store, tagline_title, body_title, attrs_title, k='title', key='tagline', key2='body')
    store.merge!({k=> {key=> tagline_title, key2=> body_title}})
    attrs.merge!({k=> attrs_title})
  end

  # utility
  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
  end

  def flatten_context(hsh, key='tagline')
    hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}
  end

  ##############################################################################
  # unrelated_params: see Description.rb
  ##############################################################################
  def unrelated_params(context, d_hsh, store)
    d_hsh.each do |k, kind_hsh|
      sub_hsh = kind_hsh.slice!(*tb_keys)
  	  flatten_params(k, kind_hsh, sub_hsh, context, store)
    end
  end

  def flatten_params(k, tb_hsh, sub_hsh, context, store)
    tb_hsh.each do |tag_key, tag_hsh|
      tag_hsh.each do |f_name, f_val|
        key = (tag_hsh.count>1 || k == 'seal'? f_name : k)
        kind_param_case(context, store, f_val, sub_hsh, key, tag_key)
      end
    end
  end

  ##############################################################################
  # build_description
  ##############################################################################
  def flat_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
    hsh['tagline'] = build_tagline(context, store)
    hsh['description'] = build_body(context, store)
    hsh['invoice_tagline'] = build_invoice_tagline(context, store)
    hsh['property_room'] = build_property_room(context, store)
    hsh['search_tagline'] = build_search_tagline(context, store)
    hsh
  end

  # tagline
  def build_tagline(context, store)
    tagline = update_tagline(context, store, valid_description_keys(store, contexts[:tagline][:keys], 'tagline'))
    tagline_punct(context, tagline, tagline.keys)
  end

  # build_invoice_tagline
  def build_invoice_tagline(context, store)
    invoice_hsh = filtered_params(store, contexts[:invoice_tagline][:keys], 'invoice_tagline', 'tagline')
    invoice_tagline = update_invoice_tagline(context, invoice_hsh.keys, invoice_hsh)
    invoice_tagline = tagline_punct(context, invoice_tagline, invoice_tagline.keys)
    Item.char_limit(invoice_tagline, contexts[:invoice_tagline][:set], 140)
  end

  def build_property_room(context, store)
    invoice_hsh = filtered_params(store, contexts[:property_room][:keys], 'property_room', 'tagline')
    property_room = update_invoice_tagline(context, invoice_hsh.keys, invoice_hsh)
    property_room = tagline_punct(context, property_room, property_room.keys)
    Item.char_limit(property_room, contexts[:property_room][:set], 128)
  end

  def build_search_tagline(context, store)
    search_hsh = filtered_params(store, contexts[:search_tagline][:keys], 'search_tagline', 'tagline')
    search_tagline = update_invoice_tagline(context, search_hsh.keys, search_hsh)
    search_tagline = tagline_punct(context, search_tagline, search_tagline.keys)
    Item.char_limit(search_tagline, contexts[:search_tagline][:set], 115)
  end

  def tagline_punct(context, tagline, keys)
    end_key, k = keys[(rev_detect(contexts[:tagline][:authentication], keys) ? -2 : -1)], rev_detect(contexts[:tagline][:media], keys)
    tagline[end_key] = tagline[end_key]+'.'
    tagline[k] = tagline[k]+',' if k != end_key
    tagline.values.join(' ')
  end

  def update_tagline(context, store, keys)
    context[:reorder].each_with_object(keys) {|h| reorder_keys(h.merge!({keys: keys}))}
    context[:remove].map {|k| remove_keys(keys,k)}
    description_params(store, keys, 'tagline')
  end

  def update_invoice_tagline(context, keys, invoice_hsh)
    keys = context[:reorder].each_with_object(keys) {|h| reorder_keys(h.merge!({keys: keys}))}
    keys.each_with_object({}){|k,h| h[k] = invoice_hsh[k]}
  end

  # description
  def build_body(context, store)
    keys = valid_description_keys(store, contexts[:body][:keys], 'body')
    reorder_keys(keys: keys, k: 'numbering', ref: 'medium', i:1) if context[:proof_edition]
    body = description_params(store, keys, 'body')
    join_title(body, keys[keys.index('title')+1])
    body_punct(context, body, body.keys)
  end

  def body_punct(context, body, keys)
    k, end_key = rev_detect(contexts[:body][:media], keys), rev_detect(contexts[:body][:authentication].reject{|k| k == 'numbering' && context[:proof_edition]}, keys)
    body[end_key] = body[end_key]+'.' if end_key
    body[k] = body[k]+(end_key ? ',' : '.')
    body.values.join(' ')
  end

  def join_title(body,k)
    body[k] = ['is', Item.indefinite_article(body[k]), body[k]].join(' ')
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

  # key-array methods ########################################################## valid_description_keys: duplicate?
  def valid_description_keys(store, keys, tag_key)
    keys.select{|k| store.dig(k,tag_key).present?}
  end
  # 84, 297, 304: replace with: filtered_hsh(h:, keys:[], dig_set:[])
  def description_params(store, keys, tag_key)
    keys.each_with_object({}) do |k,h|
      h[k] = store.dig(k,tag_key) if store.dig(k,tag_key)
    end
  end

  def filtered_params(hsh, keys, *dig_opts)
    keys.each_with_object({}) do |k,h|
      if tag_key = dig_opts.detect{|tag_key| hsh.dig(k,tag_key)}
        h[k] = hsh.dig(k,tag_key)
      end
    end
  end

  # utility methods ############################################################ #symbolize: move to textable, tb_keys: remove
  def symbolize(w)
    w.downcase.split(' ').join('_').to_sym
  end

  def tb_keys
    %w[tagline invoice_tagline tagline_search body]
  end

end

# THE END ######################################################################

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
