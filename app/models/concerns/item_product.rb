require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    p = Item.find(97).product h = Item.find(97).product.fieldables   h = Item.find(97).input_group
  def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    product_and_item_attrs(f_grp, product.tags)
    product.product_item_loop(input_params, f_grp, keys=%w[tagline body material_dimension mounting_dimension material_mounting])
    related_params(f_grp)
    shared_context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
    divergent_params(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store]) if f_grp[:context][:valid]
    f_grp
  end

  def product_and_item_attrs(f_grp, p_tags)
    product_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], product.tags)
    item_attrs(f_grp[:context], f_grp[:attrs], f_grp[:store])
  end

  def product_attrs(context, d_hsh, attrs, p_tags)
    context[product_category(p_tags['product_type'])] = true
    Medium.item_tags.map(&:to_s).map{|k| attrs[k] = p_tags[k]}
  end

  def item_attrs(context, attrs, store)
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
    artist_params(attrs, store) #unless context[:gartner_blade]
    merge_title_params(attrs, store, tagline_title, body_title, attrs_title) unless context[:gartner_blade]
  end

  ##############################################################################
  # related_params: material, mounting, dimension
  ##############################################################################
  def related_params(f_grp, args={k_key: 'dimension', k_key2: 'material', k_key3: 'mounting', sub_key: 'material_dimension', sub_key2: 'mounting_dimension'})
    merge_related_params(args[:k_key2], args[:k_key3], args[:sub_key], 'body', f_grp[:d_hsh], f_grp[:store])
    merge_related_params(args[:k_key3], args[:k_key], args[:sub_key2], args[:sub_key2], f_grp[:d_hsh], f_grp[:store])
    dimension_params(f_grp, args)
  end

  # merge_related_params #######################################################
  def merge_related_params(k_key, k_key2, sub_key, end_key, d_hsh, store)
    if k_hsh = cond_slice(d_hsh,k_key)
      sub_hsh = flatten_hsh(k_hsh).slice!(*tb_keys)
      store[k_key] = k_hsh
      if sub_tag = sub_hsh.dig(sub_key)
        Item.case_merge(d_hsh, sub_tag, k_key2, sub_key, end_key)
      end
    end
  end

  # dimension_params ###########################################################
  def dimension_params(f_grp, args)
    if valid_dimensions?(f_grp[:d_hsh], args)
      material_and_mounting_dimension_params(f_grp, args, args[:dimension]={})
    else
      attrs.merge!(attrs_dimension_params([nil]))
    end
  end

  # def valid_dimensions?(d_hsh, args)
  #   if args = dim_hsh?(d_hsh, args)
  #     if args = valid_dim_hsh?(args)
  #       args
  #     end
  #   end
  # end

  def valid_dimensions?(d_hsh, args)
    if dim_hsh?(d_hsh, args)
      valid_dim_hsh?(args)
      #   args
      # end
    end
  end
  # material_dimensions?
  def dim_hsh?(d_hsh, args)
    dimension = cond_slice(d_hsh, args[:k_key])
    args[:sub_hsh] = dimension.slice!(args[:sub_key])
    args[:dim_hsh] = args[:sub_hsh].has_key?(args[:sub_key2]) ? args[:sub_hsh].slice!(args[:sub_key2]) : args[:sub_hsh]
    dim_keys_and_material_tag(dimension[args[:sub_key]], args)
  end

  def dim_keys_and_material_tag(material_tag_hsh, args)
    return if args[:dim_hsh].empty?
    dim_name, material_tag = material_tag_hsh.to_a[0].reject{|i| i=="n/a"}
    args[:dim_keys] = dim_name.underscore.split('_')
    args[:material_tag] = weight_params(args[:dim_keys], args[:sub_hsh], material_tag)
    # args
  end
  # valid_material_dimensions?
  def valid_dim_hsh?(args)
    return unless vals_exist?(args[:dim_hsh], args[:dim_keys])
    args[:material_dimension] = args[:dim_hsh].slice(*args[:dim_keys])
    args[:material_dimension].keys.map{|k| args[:dim_hsh].delete(k)}
    # args
  end

  def material_and_mounting_dimension_params(f_grp, args, dimension)
    material_dimension_params(args[:material_dimension].values, args[:material_tag], args[:sub_key], args[:dim_keys][0], f_grp[:attrs], dimension)
    mounting_dimension_params(mounting_args(args[:dim_hsh], args[:sub_hsh].dig(args[:sub_key2]), args), f_grp[:attrs], dimension)
    body_dimensions(args[:k_key], args[:sub_key], args[:sub_key2], dimension, f_grp[:store]) if dimension.any?
    tagline_dimensions(args[:k_key], args[:sub_key], args[:sub_key2], dimension, f_grp[:store]) if dimension.any?
  end

  def material_dimension_params(material_dimensions, material_tag, sub_key, dim_type, attrs, dimension)
    attrs.merge!(attrs_dimension_params(material_dimensions[0..1]))
    dimension.merge!({sub_key=>material_dimension(material_dimensions, material_dimensions[0..1], dim_type, material_tag)})
  end

  def mounting_dimension_params(args, attrs, dimension)
    attrs.merge!(attrs_dimension_params(args[:mounting_attrs], keys: %w[frame_width frame_height]))
    dimension.merge!({args[:sub_key2]=> mounting_dimension(args[:mounting_dimension], args[:mounting_dimension][0..1], args[:mounting_tag])}) if args[:mounting_dimension]
  end

  def mounting_args(dim_hsh, mounting, args)
    args[:mounting_dimension] = (vals_exist?(dim_hsh, dim_hsh.keys) ? dim_hsh.values : nil)
    args[:mounting_tag] = (mounting && args[:mounting_dimension] ? mounting.to_a[0][-1] : nil)
    args[:mounting_attrs] = (args[:mounting_tag] == '(frame)' && args[:mounting_dimension].count >= 2 ? args[:mounting_dimension][0..1] : [nil])
    args
  end

  def tagline_dimensions(k_key, sub_key, sub_key2, dimension, store)
    key = [sub_key2, sub_key].detect{|key| dimension.has_key?(key)}
    Item.case_merge(store, "(#{dimension.dig(key,'measurements')})", k_key, 'tagline') if dimension.dig(key, 'item_size').to_i >= 1300
  end

  def body_dimensions(k_key, sub_key, sub_key2, dimension, store)
    if h = dimension.dig(sub_key)
      str = [h['measurements'], h.dig('tag')].compact.join(' ')+'.'
      str = [dimension[sub_key2]['measurements'], dimension[sub_key2]['tag']].join(' ')+', '+str if dimension.has_key?(sub_key2)
      Item.case_merge(store, "Measures approx. #{str}", k_key, 'body')
    end
  end

  def weight_params(dim_keys, sub_hsh, material_tag)
    weight_key = dim_keys.slice!(-1) if dim_keys.index('weight')
    weight_hsh = sub_hsh.slice!(*dim_keys) if weight_key
    weight = format_weight_params(weight_hsh, weight_key) if weight_hsh
    weight ? weight : material_tag
  end
  ##############################################################################

  def format_weight_params(weight_hsh, weight_key)
    if weight = weight_hsh.dig(weight_key)
      weight(weight_key, weight)
    end
  end

  def weight(weight_key, weight)
    ["#{weight}lb", "(#{weight_key})"].compact.join(' ') if weight.to_i >= 10
  end

  def material_dimension(dims, dim_set, dim_type, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, dim_type), 'tag'=> dim_tag}
  end

  def mounting_dimension(dims, dim_set, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, 'mounting'), 'tag'=> dim_tag}
  end

  # shared methods #############################################################
  def measurements(dims)
    dims.map{|i| i+"\""}.join(' x ')
  end

  def item_size(dims, dim_name=nil)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end

  # attrs_dimension_params #####################################################
  def attrs_dimension_params(dim_set, keys: ['width', 'height'])
    [keys, [dim_set[0], dim_set[-1]]].transpose.to_h
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
      gartner_blade_params(context, d_hsh, attrs, store)
    else
      flat_params(context, d_hsh, attrs, store)
    end
  end

  # gartner_blade_params #######################################################
  def gartner_blade_params(context, d_hsh, attrs, store)
    gartner_blade_attrs(d_hsh, attrs)
    gartner_blade_related_category(d_hsh, store, "\"#{attrs['title']}\"", context[:signed])
    unrelated_params(context, d_hsh, store)
    attrs.merge!(gartner_blade_description(context, store))
  end

  ## gartner_blade_attrs
  def gartner_blade_attrs(d_hsh, attrs)
    attrs.merge!({'title'=>gartner_blade_attr_title(gartner_blade_hsh(d_hsh))})
    %w[artist title].map{|k| d_hsh.delete(k)}
  end

  def gartner_blade_hsh(d_hsh)
    %w[sculpture_type sculpture_part].each_with_object({}) do |k,h|
      if tag_hsh = d_hsh.dig(k, 'tagline')
        k=='sculpture_type' ? h[k] = tag_hsh.values[0] : h.merge!(tag_hsh)
        d_hsh.delete(k)
      end
    end
  end

  def gartner_blade_attr_title(title_hsh)
    %w[size color sculpture_type lid].map{|k| title_hsh.dig(k)}.compact.join(' ')
  end

  ## gartner_blade_related_category
  def gartner_blade_related_category(d_hsh, store, title, signed, key='category')
    gartner_blade_related_tagline(d_hsh, store, title, signed, key)
    gartner_blade_related_body(d_hsh, store, title, key)
    d_hsh.delete(key)
  end

  def gartner_blade_related_tagline(d_hsh, store, title, signed, key, tag_key='tagline')
    Item.case_merge(store, [title, d_hsh[key][tag_key].values[0]+(signed ? ',' : '.')].join(' '), key, tag_key)
  end

  def gartner_blade_related_body(d_hsh, store, title, key, tag_key='body')
    category = d_hsh[key][tag_key].values[0]
    category = category.split(' ')[0..-2].join(' ') if title.downcase.index('sculpture')
    v = ["This", category].join(' ')
    Item.case_merge(store, v.sub('glass', title), key, tag_key)
  end

  def gartner_blade_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
    hsh['tagline'] = gb_tagline(context, store, valid_description_keys(store, contexts[:tagline][:keys], 'tagline'))
    hsh['description'] = gb_body(context, store, valid_description_keys(store, contexts[:body][:keys], 'body'))
    hsh
  end

  def gb_tagline(context, store, keys)
    keys = remove_keys(keys,'artist')
    description_params(store, keys, 'tagline').values.join(' ')
  end

  def gb_body(context, store, keys)
    keys = remove_keys(keys,'artist')
    reorder_keys(keys: keys, k:'text_after_title', ref: 'category', i: 1)
    description_params(store, keys, 'body').values.join(' ')
  end

  # flat_params ################################################################
  def flat_params(context, d_hsh, attrs, store)
    flat_context(context, d_hsh, store)
    unrelated_params(context, d_hsh, store)
    attrs.merge!(flat_description(context, store))
  end

  ## flat_context
  def flat_context(context, d_hsh, store)
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

  def unrelated_context(context,k,v, tagline_vals)
    if set = tagline_vals.detect{|set| v.index(set[0])}
      context[symbolize(set[-1])] = true
    end
  end

  ### nested: proof_edition, animator_seal & sports_seal
  def nested_params_context(context, d_hsh)
    context[(d_hsh['numbering']['tagline'].has_key?('proof_edition') ? :proof_edition : :numbered)] = true if d_hsh['numbering']
    %w[animator_seal sports_seal].map{|k| context[k.to_sym] = true if d_hsh['seal']['body'].has_key?(k)} if d_hsh['seal']
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
    context[:remove] << 'artist' if context[:gartner_blade]
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

  def tagline_title
    "\"#{self.title}\"" unless self.title.blank?
  end

  def body_title
    tagline_title ? tagline_title : 'This'
  end

  def attrs_title
    tagline_title ? tagline_title : 'Untitled'
  end

  # utility
  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
  end

  def flatten_context(hsh, key='tagline')
    hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}
  end

  ##############################################################################
  # unrelated_params
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
        key = (tag_hsh.count>1 ? f_name : k)
        kind_param_case(context, store, f_val, sub_hsh, key, tag_key)
      end
    end
  end

  def kind_param_case(context, store, v, sub_hsh, k, tag_key)
    case k
      when 'numbering'; numbering_params(context, store, v, sub_hsh, k, tag_key)
      when 'signature'; signature_params(context, store, v, k, tag_key)
      when 'leafing'; leafing_params(context, store, v, k, tag_key)
      when 'dated'; dated_params(context, store, v, sub_hsh, k, tag_key)
      when 'animator_seal'; animator_seal_params(context, store, v, k, tag_key)
      when 'sports_seal'; sports_seal_params(context, store, v, k, tag_key)
      when 'verification'; verification_params(context, store, v, sub_hsh, k, tag_key)
      when 'disclaimer'; disclaimer_params(context, store, v, sub_hsh, k, tag_key)
      else Item.case_merge(store, v, k, tag_key)
    end
  end

  def animator_seal_params(context, store, v, k, tag_key)
    v = v+'.' unless context[:sports_seal]
    Item.case_merge(store, v, k, tag_key)
  end

  def sports_seal_params(context, store, v, k, tag_key)
    v = v.sub('This piece bears', 'and') if context[:animator_seal]
    Item.case_merge(store, v+'.', k, tag_key)
  end

  # numbering
  def numbering_params(context, store, v, sub_hsh, k, tag_key)
    ed_val, conj = edition_value(sub_hsh), ('and' if context[:numbered_signed])
    Item.case_merge(store, [v, ed_val, conj].compact.join(' '), k, tag_key)
  end

  def edition_value(sub_hsh)
    if sub_hsh.keys.count == 2
      sub_hsh.values.join('/')
    elsif sub_hsh.keys.include?('edition_size')
      "out of #{k_hsh['edition_size']}"
    end
  end

  # signature
  def signature_params(context, store, v, k, tag_key)
    v = gartner_blade_signature(v, tag_key) if context[:gartner_blade] && !context[:unsigned]
    Item.case_merge(store, v, k, tag_key)
  end

  def gartner_blade_signature(v, tag_key)
    v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : "This piece is hand signed by GartnerBlade Glass.")
  end

  # submedia
  def leafing_params(context, store, v, k, tag_key)
    v = (context[:leafing_remarque] ? "with #{v} and" : "with #{v}")
    Item.case_merge(store, v, k, tag_key)
  end

  def remarque_params(context, store, v, k, tag_key)
    v = "with #{v}" if !context[:leafing]
    Item.case_merge(store, v, k, tag_key)
  end

  # dated
  def dated_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    Item.case_merge(store, [v, format_date(context, "(#{sub_hsh.values[0]})")].join(' '), k, tag_key)
  end

  def format_date(context, v)
    case
      when context[:numbered_signed]; v+','
      when context[:signed] || context[:numbered]; v+' and'
      else v+'.'
    end
  end

  # verification
  def verification_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    Item.case_merge(store, [v, "#{sub_hsh.values[0]}"].join(' '), k, tag_key)
  end

  # disclaimer
  def disclaimer_params(context, store, v, sub_hsh, k, tag_key)
    return if sub_hsh.none?
    v = disclaimer(v, sub_hsh.values[0]) if tag_key == 'body'
    Item.case_merge(store, v, k, tag_key)
  end

  def disclaimer(severity, damage)
    case severity
      when 'danger'; "** Please note: #{damage} **"
      when 'warning'; "Please note: #{damage}"
      when 'notation'; damage
    end
  end

  ##############################################################################
  # build_description
  ##############################################################################
  def flat_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
    hsh['tagline'] = build_tagline(context, store)
    hsh['description'] = build_body(context, store)
    hsh
  end

  # tagline
  def build_tagline(context, store)
    tagline = update_tagline(context, store, valid_description_keys(store, contexts[:tagline][:keys], 'tagline'))
    tagline_punct(context, tagline, tagline.keys)
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

  # key-array methods ##########################################################
  def valid_description_keys(store, keys, tag_key)
    keys.select{|k| store.dig(k,tag_key).present?}
  end

  def description_params(store, keys, tag_key)
    keys.each_with_object({}) do |k,h|
      h[k] = store.dig(k,tag_key) if store.dig(k,tag_key)
    end
  end

  def contexts
    {
      present_keys: %w[artist embellishing category medium sculpture_type material leafing remarque date seal certificate], #
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate]],

      tagline: {
        keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature animator_seal sports_seal certificate disclaimer],
        vals: [['Limited Edition'],['Giclee'],['Hand Pulled'],['Unsigned'],['Plate Signed', 'Signed'],['Signed'],['Signature', 'Signed'],['Disclaimer']], #['Gallery Wrapped'],['Paper'],
        media: %w[category medium sculpture_type material leafing remarque dimension],
        authentication: [:disclaimer, :unsigned]
      },

      body:{
        keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
        media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
        authentication: %w[dated numbering signature]
      }
    }
  end

  # utility methods ############################################################
  def rev_detect(set, keys)
    set.reverse.detect{|k| keys.include?(k)}
  end

  def vals_exist?(h, keys, check: :all?)
    keys.public_send(check){|k| h[k].present?}
  end

  def symbolize(w)
    w.downcase.split(' ').join('_').to_sym
  end

  def tb_keys
    %w[tagline body]
  end
end

# THE END ######################################################################
##############################################################################
##############################################################################
# def related_params(context, d_hsh, store, attrs)
#   merge_related_params('material', 'mounting', 'material_mounting', 'body', d_hsh, store)
#   merge_related_params('mounting', 'dimension', 'mounting_dimension', 'mounting_dimension', d_hsh, store)
#   dimension_params('dimension', 'material_dimension', 'mounting_dimension', d_hsh, store, attrs, context)
# end

# def dimension_params(k_key, sub_key, sub_key2, d_hsh, store, attrs, context)
#   dimension = cond_slice(d_hsh, k_key)
#   sub_hsh = dimension.slice!(sub_key)
#   dim_hsh = sub_hsh.has_key?(sub_key2) ? sub_hsh.slice!(sub_key2) : sub_hsh
#
#   if dim_hsh.any?
#     dim_name, material_tag = dimension[sub_key].to_a[0].reject{|i| i=="n/a"}
#     dim_keys = dim_name.underscore.split('_')
#     material_tag = weight_params(dim_keys, sub_hsh, material_tag)
#     material_and_mounting_dimension_params(sub_hsh, dim_hsh, k_key, sub_key, sub_key2, dim_keys, material_tag, d_hsh, store, attrs)
#   end
# end
#
# def material_and_mounting_dimension_params(sub_hsh, dim_hsh, k_key, sub_key, sub_key2, dim_keys, material_tag, d_hsh, store, attrs, hsh={})
#   material_dimension_params(dim_hsh, sub_key, dim_keys, material_tag, d_hsh, attrs, hsh)
#   mounting_dimension_params(dim_hsh, sub_hsh.dig(sub_key2), sub_key2, attrs, hsh)
#   body_dimensions(k_key, sub_key, sub_key2, hsh, store) if hsh.any?
#   tagline_dimensions(hsh, k_key, sub_key, sub_key2, store) if hsh.any?
# end

# def material_dimension_params(dim_hsh, sub_key, dim_keys, dim_tag, d_hsh, attrs, hsh)
#   if vals_exist?(dim_hsh, dim_keys)
#     material = dim_hsh.slice(*dim_keys)
#     material.keys.map{|k| dim_hsh.delete(k)}
#     format_material_dimensions(material.values, material.values[0..1], dim_keys[0], dim_tag, attrs, hsh, sub_key)
#   else
#     attrs.merge!(attrs_dimension_params([nil]))
#   end
# end

# def format_material_dimensions(dims, dim_set, dim_type, dim_tag, attrs, h, sub_key)
#   attrs.merge!(attrs_dimension_params(dim_set))
#   h.merge!({sub_key=>material_dimension(dims, dim_set, dim_type, dim_tag)})
# end

# see mounting_dimension_params 127 ##########################################
# def mounting_dimension_params(dim_hsh, mounting, sub_key, attrs, hsh)
#   if mounting
#     mounting_tag = mounting.to_a[0][-1]
#     format_mounting_dimensions(dim_hsh, sub_key, mounting_tag, (mounting_tag=='(frame)'), attrs, hsh)
#   else
#     attrs.merge!(attrs_dimension_params([nil], keys: %w[frame_width frame_height]))
#   end
# end

# see mounting_dimension_params 127, mounting_args 137 #######################
# def format_mounting_dimensions(dim_hsh, sub_key, dim_tag, framed, attrs, h)
#   if vals_exist?(dim_hsh, dim_hsh.keys) && dim_tag
#     attr_dims = framed ? dim_hsh.values[0..1] : [nil]
#     attrs.merge!(attrs_dimension_params(attr_dims, keys: %w[frame_width frame_height]))
#     h.merge!({sub_key=> mounting_dimension(dim_hsh.values, dim_hsh.values[0..1], dim_tag)})
#   end
# end

# def tagline_dimensions(hsh, k_key, sub_key, sub_key2, store)
#   key = [sub_key2, sub_key].detect{|key| hsh.has_key?(key)}
#   Item.case_merge(store, "(#{hsh.dig(key,'measurements')})", k_key, 'tagline') if hsh.dig(key, 'item_size').to_i >= 1300
# end
#
# def body_dimensions(k_key, sub_key, sub_key2, hsh, store)
#   if h = hsh.dig(sub_key)
#     str = [h['measurements'], h.dig('tag')].compact.join(' ')+'.'
#     str = [hsh[sub_key2]['measurements'], hsh[sub_key2]['tag']].join(' ')+', '+str if hsh.has_key?(sub_key2)
#     Item.case_merge(store, "Measures approx. #{str}", k_key, 'body')
#   end
# end

# def compound_keys(context, keys)
#   context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
# end
