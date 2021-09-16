require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    h = i.input_group   h = Item.find(97).input_group[:attrs]

  def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
    context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)
    related_params(f_grp[:d_hsh], f_grp[:store], f_grp[:attrs])
    unrelated_params(f_grp[:context], f_grp[:d_hsh], f_grp[:store])
    f_grp[:attrs].merge!(build_description(f_grp[:context], f_grp[:store]))
    f_grp
  end

  def build_description(context, store, hsh={'tagline'=>nil, 'description'=>nil})
    return hsh unless context[:valid] #{'tagline'=>build_tagline(context, store), 'description'=>build_body(context, store)}
    hsh['tagline'] = build_tagline(context, store)
    hsh['description'] = build_body(context, store)
    hsh
  end

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

  def update_tagline(context, store, keys)
    context[:reorder].each_with_object(keys) {|h| reorder_keys(h.merge!({keys: keys}))}
    context[:remove].map {|k| remove_keys(keys,k)}
    description_params(store, keys, 'tagline')
  end

  ##############################################################################
  def context_and_attrs(context, d_hsh, attrs, store, p_tags)
    context_hsh(d_hsh, context, p_tags)
    attrs_item_params(d_hsh, attrs, store, p_tags, context[:product_type])
  end

  # update description-keys
  def context_hsh(d_hsh, context, p_tags)
    context[:product_type] = product_category(p_tags['product_type'])
    contexts[:present_keys].map{|k| context[k.to_sym] = true if d_hsh.has_key?(k)}
    contexts[:compound_kinds].map{|kinds| compound_keys(context, kinds)}
    tagline_context(flatten_context(d_hsh), context, contexts[:tagline][:vals]) #tagline_context(flatten_context(d_hsh), context, contexts[:tagline_vals])
    kind_rules(context)
  end

  def tagline_context(tagline_hsh, context, tagline_vals)
    tagline_hsh.each do |k,v|
      if k=='numbering'
        v.index('from') ? context[:proof_edition] = true : context[:numbered] = true
      elsif set = tagline_vals.detect{|set| v.index(set[0])}
        context[set[-1].downcase.split(' ').join('_').to_sym] = true
      end
    end
  end

  def kind_rules(context)
    context[:valid] = true if context[:medium] || context[:product_type] == 'GartnerBlade'
    context[:missing] = true if context[:unsigned] && !context[:disclaimer]
    context[:signature] = true if (context[:signed] || context[:plate_signed])
    context[:numbered_signed] = true if context[:numbered] && context[:signature]
    context[:signed_certificate] = true if context[:signature] && context[:certificate]
    context[:reorder] << {k:'numbering', ref: 'medium', i: 1} if context[:proof_edition]
    context[:reorder] << {k:'embellishing', ref: 'medium'} if context[:embellishing_category] && !context[:proof_edition] && !context[:numbered]
    if h = reorder_signature(context)
      context[:reorder] << h.merge!({k: 'signature'})
    end
    context[:remove] << 'material' if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
    context[:remove] << 'medium' if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
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

  def flatten_context(d_hsh, key='tagline')
    d_hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}
  end

  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
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
  # attr_params
  ##############################################################################
  def attrs_item_params(d_hsh, attrs, store, p_tags, product_type)
    artist_params(attrs, store)
    Medium.item_tags.map(&:to_s).map{|k| attrs[k] = p_tags[k]}
    %w[sku retail qty].map{|k| attrs[k] = public_send(k)}
    title_params(d_hsh, attrs, store, product_type)
  end

  def artist_params(attrs, store)
    return unless artist
    store.merge!({'artist'=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
  end

  def title_params(d_hsh, attrs, store, product_type)
    if product_type == 'GartnerBlade'
      gartner_blade_title(d_hsh, attrs, store, Sculpture.input_group.last)
    else
      merge_title_params(attrs, store, tagline_title, body_title, attrs_title)
    end
  end

  def gartner_blade_title(d_hsh, attrs, store, title_keys)
    title_val = title_keys.map{|k| d_hsh[k]['tagline']}.reject{|i| i.blank?}
    if title_val.any?
      title = "\"#{title_val.join(' ')}\""
      merge_title_params(attrs, store, title, title, title)
      title_keys.map{|k| d_hsh.delete(k)}
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
    d_hsh.each_with_object(store) do |(k, tb_hsh), store|
      k_hsh = tb_hsh.slice!(*tb_keys)
      tb_hsh.any? ? tb_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.to_a : tb_hsh
      kind_param_case(k, tb_hsh, k_hsh, context, store)
    end
  end

  def kind_param_case(k, tb_set, k_hsh, context, store)
    case k
      when 'numbering'; numbering_params(k, tb_set, k_hsh, context, store)
      when 'leafing'; leafing_params(k, tb_set, context, store)
      when 'remarque'; remarque_params(k, tb_set, context, store)
      when 'dated'; dated_params(k, tb_set, k_hsh, context, store)
      when 'verification'; verification_params(k, tb_set, k_hsh, store)
      when 'disclaimer'; disclaimer_params(k, tb_set, k_hsh, store)
      else tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
    end
  end

  # submedia_params ###########################################################
  def leafing_params(k, tb_set, context, store)
    tb_set.map{|set| Item.case_merge(store, (context[:leafing_remarque] ? "with #{set[1]} and" : "with #{set[1]}"), k, set[0])}
  end

  def remarque_params(k, tb_set, context, store)
    tb_set.map{|set| Item.case_merge(store, (!context[:leafing] ? "with #{set[1]}" : set[1]), k, set[0])}
  end

  # numbering_params ###########################################################
  def numbering_params(k, tb_set, k_hsh, context, store)
    ed_val = edition_value(k_hsh)
    tb_set.each_with_object(store) do |set,store|
      Item.case_merge(store, [set[1], ed_val, ('and' if context[:numbered_signed])].compact.join(' '), k, set[0])
    end
  end

  def edition_value(k_hsh)
    if k_hsh.keys.count == 2
      k_hsh.values.join('/')
    elsif k_hsh.keys.include?('edition_size')
      "out of #{k_hsh['edition_size']}"
    end
  end

  # dated_params ###############################################################
  def dated_params(k, tb_set, k_hsh, context, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.map{|set| Item.case_merge(store, [set[1], format_date(context, "(#{k_hsh.values[0]})")].join(' '), k, set[0])}
  end

  def format_date(context, v)
    case
      when context[:numbered_signed]; v+','
      when context[:signature] || context[:numbered]; v+' and'
      else v+'.'
    end
  end

  # verification_params ########################################################
  def verification_params(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.map{|set| Item.case_merge(store, [set[1], "#{k_hsh.values[0]}"].join(' '), k, set[0])}
  end

  # disclaimer_params ##########################################################
  def disclaimer_params(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.each do |set|
      v = set[0] == 'body' ? disclaimer(set[1], k_hsh.values[0]) : set[1]
      Item.case_merge(store, v, k, set[0])
    end
  end

  def disclaimer(severity, damage)
    case severity
      when 'danger'; "** Please note: #{damage}. **"
      when 'warning'; "Please note: #{damage}."
      when 'notation'; damage
    end
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
      present_keys: %w[embellishing category medium material leafing remarque date seal certificate],
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:seal, :certificate]],

      tagline: {
        keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature certificate disclaimer],
        vals: [['Framed'],['Limited Edition'],['Giclee'],['Hand Pulled'],['Unsigned'],['Plate Signed'],['Signed'],['Signature', 'Signed'],['Gallery Wrapped'],['Paper'],['Disclaimer']],
        media: %w[category medium sculpture_type material leafing remarque dimension],
        authentication: [:disclaimer, :unsigned]
      },

      body:{
        keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting seal certificate dimension disclaimer],
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

  def tb_keys
    %w[tagline body]
  end
end

# THE END ######################################################################

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
