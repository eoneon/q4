require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    h = Item.find(97).product.fieldables   h = Item.find(97).input_group[:attrs]

  def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
    related_params(f_grp[:d_hsh], f_grp[:store], f_grp[:attrs])
    divergent_params(context, d_hsh, attrs, store, p_tags)
    #context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
    #unrelated_params(f_grp[:context], f_grp[:d_hsh], f_grp[:store])
    #f_grp[:attrs].merge!(build_description(f_grp[:context], f_grp[:store]))
    f_grp
  end

  ##############################################################################
  # related_params: material, mounting, dimension
  ##############################################################################

  def related_params(d_hsh, store, attrs)
    merge_related_params('material', 'mounting', 'material_mounting', 'body', d_hsh, store)
    merge_related_params('mounting', 'dimension', 'mounting_dimension', 'mounting_dimension', d_hsh, store)
    dimension_params('dimension', 'material_dimension', 'mounting_dimension', d_hsh, store, attrs)
  end

  def merge_related_params(k_key, k_key2, sub_key, end_key, d_hsh, store)
    if k_hsh = d_hsh[k_key]
      sub_hsh = k_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.slice!(*tb_keys)
      store[k_key] = k_hsh
      Item.case_merge(d_hsh, sub_hsh[sub_key], k_key2, sub_key, end_key) if sub_hsh[sub_key]
      d_hsh.delete(k_key)
    end
  end

  def dimension_params(k_key, sub_key, sub_key2, d_hsh, store, attrs, hsh={})
    if k_hsh = d_hsh[k_key]
      sub_hsh = k_hsh.slice!(sub_key)
      dim_keys, dim_tag = k_hsh[sub_key].keys[0].underscore.split('_'), k_hsh[sub_key].values.reject{|v| v=='n/a'}[0]
      material_dimension_params(sub_hsh, sub_key, dim_keys, dim_tag, d_hsh, attrs, hsh)
      mounting_dimension_params(sub_hsh, sub_key2, attrs, hsh)
      body_dimensions(k_key, sub_key, sub_key2, hsh, store) if hsh.any?
      tagline_dimensions(hsh, k_key, sub_key, sub_key2, store) if hsh.any?
      d_hsh.delete(k_key)
    end
  end

  # material_dimension_params ##################################################
  def material_dimension_params(sub_hsh, sub_key, dim_keys, dim_tag, d_hsh, attrs, hsh)
    if vals_exist?(sub_hsh, dim_keys)
      dim_hsh = sub_hsh.slice(*dim_keys)
      format_material_dimensions(dim_hsh.values, dim_hsh.values[0..1], dim_keys[0], dim_tag, attrs, hsh, sub_key)
    else
      attrs.merge!(attrs_dimension_params([nil]))
    end
    dim_keys.map{|k| sub_hsh.delete(k)}
  end

  def format_material_dimensions(dims, dim_set, dim_type, dim_tag, attrs, h, sub_key)
    attrs.merge!(attrs_dimension_params(dim_set))
    h.merge!({sub_key=>material_dimension(dims, dim_set, dim_type, dim_tag)})
  end

  def material_dimension(dims, dim_set, dim_type, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, dim_type), 'tag'=> dim_tag}
  end

  # mounting_dimension_params ##################################################
  def mounting_dimension_params(sub_hsh, sub_key, attrs, hsh)
    if sub_hsh.has_key?(sub_key)
      dim_hsh = sub_hsh.slice!(sub_key) #dim_tag = sub_hsh.values[0]
      dim_tag, framed = sub_hsh[sub_key].values[0], (sub_hsh.values[0]=='(frame)')
      format_mounting_dimensions(dim_hsh, sub_key, dim_tag, framed, attrs, hsh)
    else
      attrs.merge!(attrs_dimension_params([nil], keys: %w[frame_width frame_height]))
    end
  end

  def format_mounting_dimensions(dim_hsh, sub_key, dim_tag, framed, attrs, h)
    if vals_exist?(dim_hsh, dim_hsh.keys) && dim_tag
      attr_dims = framed ? dim_hsh.values[0..1] : [nil]
      attrs.merge!(attrs_dimension_params(attr_dims, keys: %w[frame_width frame_height]))
      h.merge!({sub_key=> mounting_dimension(dim_hsh.values, dim_hsh.values[0..1], dim_tag)})
    end
  end

  def mounting_dimension(dims, dim_set, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, 'mounting'), 'tag'=> dim_tag}
  end

  #shared methods ##############################################################
  def measurements(d_names)
    d_names.map{|i| i+"\""}.join(' x ')
  end

  def item_size(dims, dim_name=nil)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end

  def tagline_dimensions(hsh, k_key, sub_key, sub_key2, store)
    key = [sub_key2, sub_key].detect{|key| hsh.has_key?(key)}
    Item.case_merge(store, "(#{hsh.dig(key,'measurements')})", k_key, 'tagline') if hsh.dig(key, 'item_size').to_i >= 1300
  end

  def body_dimensions(k_key, sub_key, sub_key2, hsh, store)
    if h = hsh.dig(sub_key)
      str = [h['measurements'], h.dig('tag')].compact.join(' ')+'.'
      str = [hsh[sub_key2]['measurements'], hsh[sub_key2]['tag']].join(' ')+', '+str if hsh.has_key?(sub_key2)
      Item.case_merge(store, "Measures approx. #{str}", k_key, 'body')
    end
  end

  # attrs_dimension_params #####################################################
  def attrs_dimension_params(dim_set, keys: ['width', 'height'])
    [keys, [dim_set[0], dim_set[-1]]].transpose.to_h
  end

  ##############################################################################
  # divergent_params
  ##############################################################################
  def divergent_params(context, d_hsh, attrs, store, p_tags)
    shared_context(context, d_hsh, attrs, store, p_tags)
    if context[:gartner_blade]
      gartner_blade_params(context, d_hsh, attrs, store)
    else context[:valid]
      flat_params(context, d_hsh, attrs, store)
    end
  end

  def shared_context(context, d_hsh, attrs, store, p_tags)
    attr_params(attrs, p_tags)
    d_hsh.keys.map{|k| context[k.to_sym] = true if contexts[:present_keys].include?(k)}
    context[:product_type] = product_category(p_tags['product_type'].underscore.to_sym #context[:gartner_blade] = true if context[:product_type] == 'GartnerBlade' && context[:sculpture_type]
    context[:valid] = true if context[:medium] || (context[:gartner_blade] && context[:sculpture_type])
    context[:missing] = true if context[:unsigned] && !context[:disclaimer]
  end

  def gartner_blade_params(context, d_hsh, attrs, store)
    remove_rules(context)
    gartner_blade_attrs(d_hsh, attrs, store)
  end

  def gartner_blade_attrs(d_hsh, attrs, store)
    attrs.merge!(artist.artist_params['attrs'])
    gartner_blade_title(d_hsh, attrs, store, gartner_blade_hsh(d_hsh))
  end

  def flat_params(context, d_hsh, attrs, store)
    flat_context(context, d_hsh, store)
    flat_attrs(attrs, store)
    unrelated_params(context, d_hsh, store)
    attrs.merge!(flat_description(context, store))
  end

  def flat_context(context, d_hsh, store)
    params_context(context, d_hsh, store)
    nested_params_context(context, d_hsh)
    contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
    reorder_remove(context)
  end

  def flat_attrs(attrs, store)
    artist_params(attrs, store)
    merge_title_params(attrs, store, tagline_title, body_title, attrs_title)
  end
  
  ##############################################################################
  # context_and_attrs
  ##############################################################################
  # def context_and_attrs(context, d_hsh, attrs, store, p_tags)
  #   d_hsh.keys.map{|k| context[k.to_sym] = true if contexts[:present_keys].include?(k)}
  #   context_hsh(context, d_hsh, store, p_tags)
  #   attrs_item_params(d_hsh, attrs, store, p_tags, context[:gartner_blade])
  # end

  ## context_hsh
  # def context_hsh(context, d_hsh, store, p_tags)
  #   params_context(context, d_hsh, store)
  #   nested_params_context(context, d_hsh)
  #   misc_context(context, p_tags)
  #   reorder_remove(context)
  # end

  # params: related: material, mounting & dimension - unrelated: tag_vals & present_keys
  def params_context(context, d_hsh, store)
    store.each {|k,v| related_context(context,k,v['tagline'])}
    flatten_context(d_hsh).each {|k,v| unrelated_context(context,k,v, contexts[:tagline][:vals])}
  end

  def related_context(context,k,v)
    if k=='dimension'
      context[k.to_sym] = true
    elsif %w[material mounting].include?(k)
      if i = ['Framed', 'Gallery Wrapped', 'Rice', 'Paper'].detect{|i| v.index(i)}
        context[symbolize(i)] = true
      end
    end
  end

  def unrelated_context(context,k,v, tagline_vals)
    #context[k.to_sym] = true if contexts[:present_keys].include?(k)
    if set = tagline_vals.detect{|set| v.index(set[0])}
      context[symbolize(set[-1])] = true
    end
  end

  # nested: proof_edition, animator_seal & sports_seal
  def nested_params_context(context, d_hsh)
    context[(d_hsh['numbering']['tagline'].has_key?('proof_edition') ? :proof_edition : :numbered)] = true if d_hsh['numbering']
    %w[animator_seal sports_seal].map{|k| context[k.to_sym] = true if d_hsh['seal']['body'].has_key?(k)} if d_hsh['seal']
  end

  # misc: product_type, valid, missing & compound_kinds
  # def misc_context(context, p_tags)
  #   context[:product_type] = product_category(p_tags['product_type'])
  #   context[:gartner_blade] = true if context[:product_type] == 'GartnerBlade' && context[:sculpture_type]
  #   context[:valid] = true if context[:medium] || context[:gartner_blade]
  #   context[:missing] = true if context[:unsigned] && !context[:disclaimer]
  #   contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
  # end

  # def misc_context(context)
  #   contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
  # end

  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
  end

  # reorder_remove
  def reorder_remove(context)
    reorder_rules(context) unless context[:gartner_blade]
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

  # utility
  def flatten_context(hsh, key='tagline')
    hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}
  end

  ## attr_params: artist, title, sku, retail, qty & :art_type, :art_category, :item_type, :item_category, :medium, :material
  # def attrs_item_params(d_hsh, attrs, store, p_tags, gartner_blade)
  #   artist_params(attrs, store)
  #   Medium.item_tags.map(&:to_s).map{|k| attrs[k] = p_tags[k]}
  #   %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
  #   title_params(d_hsh, attrs, store, gartner_blade)
  # end

  def attr_params(attrs, p_tags)
    Medium.item_tags.map(&:to_s).map{|k| attrs[k] = p_tags[k]}
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
  end

  # artist
  def artist_params(attrs, store)
    return unless artist
    store.merge!({'artist'=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
  end

  # title
  def title_params(d_hsh, attrs, store, gartner_blade)
    if gartner_blade
      gartner_blade_title(d_hsh, attrs, store, gartner_blade_hsh(d_hsh))
    else
      merge_title_params(attrs, store, tagline_title, body_title, attrs_title)
    end
  end

  def gartner_blade_title(d_hsh, attrs, store, title_hsh)
    title_val = %w[size color sculpture_type lid].map{|k| title_hsh.dig(k)}.compact
    if title_val.any?
      attr_title = title_val.join(' ')
      merge_title_params(attrs, store, "\"#{attr_title}\"", "This hand blown \"#{attr_title}\"", attr_title)
    end
  end

  def gartner_blade_hsh(d_hsh)
    %w[sculpture_type sculpture_part].each_with_object({}) do |k,h|
      if tag_hsh = d_hsh.dig(k, 'tagline')
        tag_hsh.count>1 ? h.merge!(tag_hsh) : h[k] = tag_hsh.values[0]
        d_hsh.delete(k)
      end
    end
  end

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
      when 'text_after_title'; text_after_title_params(context, store, v, k, tag_key)
      when 'numbering'; numbering_params(context, store, v, sub_hsh, k, tag_key)
      when 'signature'; signature_params(context, store, v, k, tag_key)
      when 'leafing'; leafing_params(context, store, v, k, tag_key)
      when 'dated'; dated_params(context, store, v, sub_hsh, k, tag_key)
      when 'verification'; verification_params(context, store, v, sub_hsh, k, tag_key)
      when 'disclaimer'; disclaimer_params(context, store, v, sub_hsh, k, tag_key)
      else Item.case_merge(store, v, k, tag_key)
    end
  end

  #text_after_title
  def text_after_title_params(context, store, v, k, tag_key)
    v = gartner_blade_text_after_title(context, v) if context[:gartner_blade]
    Item.case_merge(store, v, k, tag_key)
  end

  def gartner_blade_text_after_title(context, v)
    v = (context[:signed] ? "#{v}," : "#{v}."))
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
    v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : v.sub('the artist', 'GartnerBlade Glass.'))
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
      when 'danger'; "** Please note: #{damage}. **"
      when 'warning'; "Please note: #{damage}."
      when 'notation'; damage
    end
  end

  ##############################################################################
  # build_description
  ##############################################################################
  def flat_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
    return hsh unless context[:valid]
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
    puts "k: #{k}, end_key: #{end_key}, keys: #{keys}"
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
      h[k] = store.dig(k,tag_key) if store[k].has_key?(tag_key)
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
# def unrelated_params(context, d_hsh, store)
#   d_hsh.each_with_object(store) do |(k, tb_hsh), store|
#     k_hsh = tb_hsh.slice!(*tb_keys)
#     tb_hsh.any? ? tb_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.to_a : tb_hsh
#     kind_param_case(k, tb_hsh, k_hsh, context, store)
#   end
# end
#
# def kind_param_case(k, tb_set, k_hsh, context, store)
#   case k
#     when 'numbering'; numbering_params(k, tb_set, k_hsh, context, store)
#     when 'leafing'; leafing_params(k, tb_set, context, store)
#     when 'remarque'; remarque_params(k, tb_set, context, store)
#     when 'dated'; dated_params(k, tb_set, k_hsh, context, store)
#     when 'verification'; verification_params(k, tb_set, k_hsh, store)
#     when 'disclaimer'; disclaimer_params(k, tb_set, k_hsh, store)
#     else tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
#   end
# end

# def dated_params(k, tb_set, k_hsh, store)
#   return if tb_set.none? && k_hsh.none?
#   tb_set.map{|set| Item.case_merge(store, [set[1], "(#{k_hsh.values[0]})"].join(' '), k, set[0])}
# end

# def build_tagline(context, store)
#   if context[:valid]
#     tagline = update_tagline(context, store, valid_description_keys(store, contexts[:tagline][:keys], 'tagline'))
#     store['tagline'] = tagline_punct(context, tagline, tagline.keys)
#   end
# end

# def build_body(context, store)
#   if context[:valid]
#     keys = valid_description_keys(store, contexts[:body][:keys], 'body')
#     reorder_keys(keys: keys, k: 'numbering', ref: 'medium', i:1) if context[:proof_edition]
#     body = description_params(store, keys, 'body')
#     join_title(body, keys[keys.index('title')+1])
#     store['body'] = body_punct(context, body, body.keys.reject{|k| k = 'numbering' && !context[:proof_edition]})
#   end
# end

# def validated_slice(h, keys, test: :all?)
#   h.slice!(*keys) if valid_slice?(h, keys, test)
# end
#
# def valid_slice?(h, keys, check)
#   keys.public_send(check){|k| h[k].present?}
# end
