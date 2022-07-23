require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern

  def form_and_datas(action:nil, store:{})
    p = product
    return [[], {}] if !p
    input_group = config_inputs_and_d_hsh(fields: p.unpacked_fields)
    config_form_group(input_group, p.tags)
    return input_group[:rows] if action == 'show'

    item_product_attrs(p.tags, input_group[:context], input_group[:attrs], input_group[:d_hsh])
    contexts[:compound_kinds].map{|kinds| compound_keys(input_group[:context], kinds)}
    config_dependent_kinds(input_group, input_group[:context], input_group[:d_hsh])

    #config_kind_params_and_contexts(input_group, input_group[:d_hsh])
    #config_kind_params_and_contexts(input_group[:context], input_group[:attrs], input_group[:d_hsh])
    #input_group[:attrs].merge!(flat_description(input_group[:context], input_group[:d_hsh]))
    #[input_group[:attrs], input_group[:context], input_group[:d_hsh]]
  end

  def config_kind_params_and_contexts(input_group, d_hsh)
  	config_dependent_kinds(input_group, d_hsh)
    d_hsh
    # final_contexts(context)
    # d_hsh.keys.map{|k| kind_params_case(k, context, attrs, d_hsh)}
    # reorder_remove(context.merge!({reorder:[], remove:[]}))
  end
  ##############################################################################
  # def config_dependent_kinds(input_group, context,d_hsh)
  #   [['numbering', LimitedEdition], ['dimension', Dimension], ['disclaimer', Disclaimer], ['dated', Authentication], ['verification', Authentication], ['animator_seal', Authentication], ['sports_seal', Authentication]].each do |k|
  #     if k_hsh = hsh_slice_and_delete(d_hsh, k[0])
  #       k[-1].public_send("config_#{k[0]}", k[0], k_hsh, input_group, context, d_hsh)
  #     end
  #   end
  #   d_hsh
  # end

  def config_dependent_kinds(input_group, context, d_hsh)
    contexts[:dependent_kinds].each_with_object(d_hsh) do |(klass, kinds), d_hsh|
      kinds.each do |k|
        if k_hsh = hsh_slice_and_delete(d_hsh, k)
          to_class(klass).public_send("config_#{k}", k, k_hsh, input_group, context, d_hsh)
        end
      end
    end
  end
  ##############################################################################
  def kind_params_case(k, context, attrs, d_hsh)
  	case k
  		when 'numbering'; config_numbering_params(k, context, attrs, d_hsh)
      when 'dimension'; config_dimension_params(k, context, attrs, d_hsh)
  		when 'disclaimer'; config_disclaimer_params(k, context, d_hsh)
      when %w[dated verification].include?(k); config_auth_params(k, context, d_hsh)
  		when 'leafing'; config_leafing_params(k, context, d_hsh)
      when 'remarque'; config_remarque_params(k, context, d_hsh)
      #when 'title'; config_remarque_params(k, context, d_hsh)
  	end
  end

  def config_numbering_params(k, context, attrs, d_hsh)
  	numbering_hsh = hsh_slice_and_delete(d_hsh, k)
  	edition_hsh = numbering_hsh.slice!(*tb_keys)
  	LimitedEdition.config_numbering_params(k, numbering_hsh, edition_hsh.reject{|k,v| v.blank?}, context, attrs, d_hsh)
  end

  def config_leafing_params(k, context, d_hsh)
  	transform_params(d_hsh[k], 'and', 1) if context[:leafing_remarque]
  end

  def config_remarque_params(k, context, d_hsh)
    transform_params(d_hsh[k], 'with') if !context[:leafing]
  end

  def config_related_params(k, context, attrs, d_hsh)
  	related_hsh = hsh_slice_and_delete(d_hsh, k)
  	Dimension.new.config_related_params(related_hsh, d_hsh, context, attrs)
  end

  def config_dimension_params(k, context, attrs, d_hsh)
  	dimension_hsh = hsh_slice_and_delete(d_hsh, k)
    Dimension.new.config_dimension_params(k, dimension_hsh, d_hsh, context, attrs)
  end

  def config_auth_params(k, context, d_hsh)
  	auth_hsh = hsh_slice_and_delete(d_hsh, k)
  	sub_hsh = auth_hsh.slice!(*tb_keys)
    if sub_hsh.any?
  		Authentication.config_auth_params(k, sub_hsh.values[0], auth_hsh, context, d_hsh)
      d_hsh[k].transform_values!{|v| format_date(context, v)} if k=='dated'
  	end
  end

  def config_seal_params(k, context, d_hsh)
    seal_hshs = hsh_slice_and_delete(d_hsh, k)
    seal_hshs.keys.map{|seal_key| context[seal_key.to_sym] = true}
    seal_hshs.each {|seal_key, seal_hsh| Authentication.config_seal_params(seal_key, seal_hsh, context, d_hsh)}
  end

  def config_disclaimer_params(k, context, d_hsh)
  	disclaimer_hsh = hsh_slice_and_delete(d_hsh, k)
  	damage_hsh = disclaimer_hsh.slice!(*tb_keys)
  	Disclaimer.config_disclaimer_params(k, disclaimer_hsh['body'], damage_hsh.values[0], disclaimer_hsh, context, d_hsh)
  end

  def final_contexts(context)
  	#context[:valid] = true if context[:medium] || context[:sculpture_type]
    #contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
    #context[:embellishing_after_medium] = true if context[:embellishing_category] && !context[:numbering]
  	#context[:signature_last] = true if context[:unsigned] && !context[:disclaimer]
  end

  # def config_context(k, context, d_hsh)
  # 	context[symbolize(k)] = true if contexts[:present_keys].include?(k)
  # 	check_tagline_context(d_hsh.dig(k, 'tagline'), context) if %w[category medium material signature disclaimer].include?(k)
  # end

  # def check_tagline_context(tagline_val, context)
  # 	return unless tagline_val
  # 	if val_and_key = contexts[:tagline][:vals].detect{|val_and_key| tagline_val.index(val_and_key[0])}
  # 		context[symbolize(val_and_key[-1])] = true
  # 	end
  # end

  # def final_contexts(context)
  # 	contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
  # 	context[:valid] = true if context[:medium] || context[:sculpture_type]
  # 	context[:signature_last] = true if context[:unsigned] && !context[:disclaimer]
  # end

  def transform_params(params, conj, push=nil)
  	params.transform_values!{|tag_val| push ? "#{tag_val} #{conj}" : "#{conj} #{tag_val}"}
  end

  def description_grammar(d_hsh, context)
  	%w[leafing remarque numbering signature dated].each do |k|
  		next if d_hsh.keys.exclude?(k)
  		case
  			when k=='numbering' && context[:numbered_signed]; transform_params(d_hsh[k], 'and', 1)
  			when k=='leafing' && context[:leafing_remarque]; transform_params(d_hsh[k], 'and', 1)
  			when k=='remarque' && !context[:leafing]; transform_params(d_hsh[k], 'with')
  			when k=='dated'; d_hsh[k].transform_values!{|tag_val| format_date(context, tag_val)}
  		end
  	end
  end
  ##############################################################################
  # def item_product_attrs(p_tags, d_hsh, f_grp)
  #   init_attrs(f_grp)
  #   Medium.tag_keys.map{|k| f_grp[:attrs][k] = p_tags[k]}
  #   %w[sku retail qty].map{|k| f_grp[:attrs][k] = public_send(k)}
  #   artist_params(f_grp[:context], f_grp[:attrs], d_hsh)
  #   merge_title_params(f_grp[:attrs], d_hsh, tagline_title, body_title, attrs_title) unless f_grp[:context][:gartner_blade]
  # end

  def item_product_attrs(p_tags, context, attrs, d_hsh)
    init_attrs(attrs)
    Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
    artist_params(context, attrs, d_hsh)
    merge_title_params(attrs, d_hsh, tagline_title, body_title, attrs_title) unless context[:gartner_blade]
  end

  def init_attrs(attrs)
    #f_grp.merge!({:attrs=>default_hsh(*contexts[:csv][:export])})
    attrs.merge!(default_hsh(*contexts[:csv][:export]))
  end

  def artist_params(context, attrs, d_hsh)
    return unless artist
    context[:artist] = true
    d_hsh.merge!({'artist'=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
  end

  def merge_title_params(attrs, d_hsh, tagline_title, body_title, attrs_title, k='title', key='tagline', key2='body')
    d_hsh.merge!({k=> {key=> tagline_title, key2=> body_title}})
    attrs[k] = attrs_title
  end
  ##############################################################################
  def set_tagline_vals_context(k, v, context)
  	if tagline_vals = contexts[:tagline].dig(k.to_sym)
  		set_tagline_val_context(v, context, tagline_vals)
  	end
  end

  def set_tagline_val_context(v, context, tagline_vals)
  	if set = tagline_vals.detect{|set| v.index(set[0])}
  		context[symbolize(set[-1])] = true
  	end
  end
  # def form_and_data(action:nil, f_grp:{context: {reorder:[], remove:[]}, attrs:{}, store:{}})
  # 	return [[], {}] if !product
  #   p = product
  #   #product.config_form_group(f_grp.merge!(inputs_and_tag_hsh(input_group: param_group)))
  #   product.product_attrs(context, attrs)
  #   product.config_form_group(f_grp.merge!(get_inputs_and_tag_hsh))
  # 	return f_grp[:rows] if action == 'show'
  # 	related_and_divergent_params(f_grp)
  # 	[f_grp[:rows], f_grp[:attrs]]
  # end

  def form_and_data(action:nil, f_grp:{context: {reorder:[], remove:[]}, attrs:{}, store:{}})
    p = product
    return [[], {}] if !p
    p.product_attrs(f_grp)
    #f_grp[:param_hsh] = config_params(fieldables)
    f_grp.merge!(get_inputs_and_tag_hsh(fields: p.unpacked_fields))
    f_grp[:rows] = build_form_rows(f_grp[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
    f_grp[:d_hsh] = f_grp[:tag_hsh]
    return f_grp[:rows] if action == 'show'
    related_and_divergent_params(f_grp)
    [f_grp[:rows], f_grp[:attrs]]
  end

  ##############################################################################


  ##############################################################################
  # def product_attrs(p_tags, f_grp)
  #   f_grp[:context][product_category(p_tags['product_type'])] = true
  #   Medium.tag_keys.map{|k| f_grp[:attrs][k] = tags[k]}
  # end

  def item_attrs(f_grp)
    %w[sku retail qty].map{|k| f_grp[:attrs][k] = public_send(k)}
    artist_params(f_grp[:context], f_grp[:attrs], f_grp[:store])
    merge_title_params(f_grp[:attrs], f_grp[:store], tagline_title, body_title, attrs_title) unless f_grp[:context][:gartner_blade]
  end

  def related_and_divergent_params(f_grp)
    item_attrs(f_grp[:context], f_grp[:attrs], f_grp[:store])
    f_grp[:attrs].merge!(default_hsh('width', 'height', 'frame_width', 'frame_height'))
    related_params(f_grp)
    shared_context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
    divergent_params(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store]) if f_grp[:context][:valid]
  end

  ##############################################################################
  # related_params II: material, mounting, dimension: see Dimension.rb
  ##############################################################################
  def related_params(f_grp)
    contexts[:related_args].each do |args|
      puts "args=>  #{args}"
      if k_hsh = slice_and_delete(f_grp[:d_hsh], args[:k])
        puts "k_hsh=> #{k_hsh}, d_hsh=> #{f_grp[:d_hsh]}"
        Dimension.new.material_mounting_dimension_params(k_hsh, f_grp, args)
      end
    end
  end
  ##############################################################################
  # shared_context_and_attrs
  ##############################################################################
  def shared_context_and_attrs(context, d_hsh, attrs, store, p_tags)
    d_hsh.keys.map{|k| context[k.to_sym] = true if contexts[:present_keys].include?(k)}
    d_hsh.select{|k,h| h['tagline']}.each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
    #flatten_context(d_hsh).each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
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
  # def nested_params_context(context, d_hsh)
  #   context[(d_hsh['numbering']['tagline'].has_key?('proof_edition') ? :proof_edition : :numbered)] = true if d_hsh['numbering']
  #   %w[animator_seal sports_seal].map{|k| context[k.to_sym] = true if d_hsh['seal']['body'].has_key?(k)} if d_hsh['seal']
  # end
  def nested_params_context(context, d_hsh)
    context[(d_hsh['numbering'].has_key?('proof_edition') ? :proof_edition : :numbered)] = true if d_hsh['numbering']
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
        key = (tag_hsh.count>1 || k == 'seal' ? f_name : k)
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
    puts "store=>#{store}"
    puts "store.class=>#{store.class}"
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

  #new refactor #############################################################################
  # def config_form_group(input_group, tags, f_grp)
  #   f_grp[:context][product_category(tags['product_type'])] = true
  #   f_grp[:rows] = build_form_rows(input_group[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
  #   #f_grp[:rows] = build_form_rows(hsh_slice_and_delete(input_group[:inputs]).group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
  # end

  def config_form_group(input_group, tags)
    input_group[:context][product_category(tags['product_type'])] = true
    input_group[:rows] = build_form_rows(input_group[:inputs].group_by{|h| h[:k]}, media_group(input_group[:context]).merge!(form_groups))
    #f_grp[:rows] = build_form_rows(hsh_slice_and_delete(input_group[:inputs]).group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
  end
  ##############################################################################

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
