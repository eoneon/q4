require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    p = Item.find(97).product h = Item.find(97).product.fieldables   h = Item.find(97).input_group
  def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    product.product_item_loop(input_params, f_grp, keys=%w[tagline body material_dimension mounting_dimension material_mounting])
    related_and_divergent_params(f_grp)
    f_grp
  end

  def item_attrs(context, attrs, store)
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
    artist_params(attrs, store) #unless context[:gartner_blade]
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
  # related_params II: material, mounting, dimension: 7
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
    v = (context[:leafing_remarque] ? "#{v} and" : v)
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

  def contexts
    {
      present_keys: %w[artist embellishing category medium sculpture_type material leafing remarque date seal certificate], #
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate]],
      related_args: [
        {k: 'material', related: 'mounting', d_tag: 'material_dimension', end_key: 'body'},
        {k: 'mounting', related: 'dimension', d_tag: 'mounting_dimension', end_key: 'mounting_dimension'},
        {k: 'dimension', d_tag: 'material_dimension', d_tag2: 'mounting_dimension', material_dimensions: nil, mounting_dimensions: nil, material_tag: nil, mounting_tag: nil}
      ],

      gartner_blade: %w[category text_after_title sculpture_type sculpture_part signature dimension disclaimer],

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

  # utility methods ############################################################ #symbolize: move to textable, tb_keys: remove
  def symbolize(w)
    w.downcase.split(' ').join('_').to_sym
  end

  def tb_keys
    %w[tagline body]
  end
end

# THE END ######################################################################

# def compound_keys(context, keys)
#   context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
# end
