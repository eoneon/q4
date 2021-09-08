require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    h = i.input_group   h = Item.find(97).input_group

  def input_group(f_grp={rows:[], context:{reorder:[], remove:[]}, d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
    context_and_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], f_grp[:store], product.tags)

    related_params(f_grp[:d_hsh], f_grp[:store], f_grp[:attrs])
    unrelated_params(f_grp[:context], f_grp[:d_hsh], f_grp[:store])

    build_tagline(f_grp[:context], f_grp[:store])
    build_body(f_grp[:context], f_grp[:store])

    f_grp
  end

  def build_tagline(context, store)
    if store.keys.include?('medium')
      tagline = update_tagline(context, store, valid_description_keys(store, tagline_keys, 'tagline'))
      store['tagline'] = tagline.values.join(' ')
    end
  end

  def build_body(context, store)
    if store.keys.include?('medium')
      keys = valid_description_keys(store, body_keys, 'body')
      reorder_keys(keys: keys, k: 'numbering', ref: 'material') if context[:proof_edition]
      body = description_params(store, keys, 'body')
      store['body'] = body.values.join(' ')
    end
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
    tagline_context(flatten_context(d_hsh), context, contexts[:tagline_vals])
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
    context[:missing] = true if context[:unsigned] && !context[:disclaimer]
    context[:signature] = true if (context[:signed] || context[:plate_signed])
    context[:numbered_signed] = true if context[:numbered] && context[:signature]
    context[:signed_certificate] if context[:signature] && context[:certificate]
    context[:remove] << 'material' if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
    context[:remove] << 'medium' if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
    context[:reorder] << {k:'embellishing', ref: 'medium'} if context[:embellishing_category] && !context[:proof_edition] && !context[:numbered]
    context[:reorder] << {k:'numbering', ref: 'material'} if context[:proof_edition] && context[:remove].exclude?('material')
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
      when 'dated'; dated_params(k, tb_set, k_hsh, store)
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
  def dated_params(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.map{|set| Item.case_merge(store, [set[1], "(#{k_hsh.values[0]})"].join(' '), k, set[0])}
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

  def tagline_keys
    %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature certificate disclaimer]
  end

  def body_keys
    %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting seal certificate dimension disclaimer]
  end

  def contexts
    {
      present_keys: %w[embellishing category leafing remarque date seal certificate],
      tagline_vals: [['Framed'],['Limited Edition'],['Giclee'],['Hand Pulled'],['Unsigned'],['Plate Signed'],['Signed'],['Signature', 'Signed'],['Gallery Wrapped'],['Paper'],['Disclaimer']],
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:seal, :certificate]]
    }
  end

  # utility methods ############################################################
  def vals_exist?(h, keys, check: :all?)
    keys.public_send(check){|k| h[k].present?}
  end

  def tb_keys
    %w[tagline body]
  end
end

# THE END ######################################################################

#context[:remove_giclee] = true if context[:giclee_paper] && context[:embellished_category] || context[:giclee] && !context[:paper] && [:category, :embellishing].one?{|k| context[k]}

# def validated_slice(h, keys, test: :all?)
#   h.slice!(*keys) if valid_slice?(h, keys, test)
# end
#
# def valid_slice?(h, keys, check)
#   keys.public_send(check){|k| h[k].present?}
# end


  # signature_params ###########################################################
  # def signature_params(k, tb_set, context, store)
  #   #:numbered_signed || :numbered_plate_signed
  #   tb_set.map{|set| Item.case_merge(store, (context[:signed_and_numbered] ? "#{set[1]} and" : set[1]), k, set[0])}
  # end

  # def context_loop(d_hsh, context, key='tagline')
  #   d_hsh.select{|k,h| h[key]}.transform_values{|h| h[key].values[0]}.each do |k,v|
  #     kind_context_case(k, v, context)
  #   end
  # end

  # def kind_context_case(k, v, context)
  #   case
  #     when v=='(Unsigned)'; context[:missing_signature] = true
  #     when v=='(Disclaimer)'; context[:danger] = true
  #     when v=='Framed'; context[:framed] = true
  #     when v.index('Giclee'); context[:giclee] = true
  #     when v.index('Hand Pulled'); context[:hand_pulled] = true
  #     when v.index('Gallery'); context[:gallery_wrapped] = true
  #     when k=='numbering' && v.index('from'); context[:from_an_edition] = true
  #     when v.index('Paper'); context[:paper] = true
  #     when v.index('Limited Edition'); context[:limited_edition] = true
  #     when k=='signature'; context[:signed] = true
  #     when k=='numbering'; context[:numbered] = true
  #     when %w[artist category embellishing leafing remarque date seal certificate].include?(k); context[k.to_sym] = true
  #   end
  # end

  # def compound_kind_context_case(context)
  #   context[:numbered_and_signed] = true if [:signed, :numbered].all?{|k| context[k]}
  #   context[:signed_with_certificate] = true if [:signed, :certificate].all?{|k| context[k]}
  #   context[:two_submedia] = true if [:leafing, :remarque].all?{|k| context[k]}
  #   context[:reorder_embellishing] = true if context[:embellishing] && context[:category] && !context[:limited_edition]
  #   context[:unsigned] = true if !context[:signed] && !context[:missing_signature]
  #   context[:shift_signature] = true if context[:missing_signature] && !context[:danger]
  #   context[:skip_signature] = true if context[:unsigned] || [:missing_signature, :danger].all?{|k| context[k]}
  #   context[:giclee_on_paper] = true if context[:giclee] && context[:paper]
  #   context[:skip_paper] = true if context[:paper] && ![:category, :embellishing, :hand_pulled, :leafing, :remarque, :signed, :certificate].any?{|k| context[k]}
  #   context[:remove_giclee] = true if context[:giclee_on_paper] && [:category, :embellishing].all?{|k| context[k]} || context[:giclee] && !context[:paper] && [:category, :embellishing].all?{|k| context[k]}
  #   context[:reorder_signature] = true if context[:giclee] && !context[:numbered_and_signed] && !context[:signed_with_certificate]
  # end

  # def present_key_context(d_hsh, context, present_keys)
  #   present_keys.map{|k| context[k.to_sym] = true if d_hsh.has_key?(k)}
  # end

  # # tagline_hsh: flatten_context(d_hsh)

  #
  # def kind_context_case(context,compound_kinds)
  #   compound_kinds.map{|kinds| compound_keys(context, kinds)}
  # end

# def attrs_context_hsh(context, d_hsh, attrs, store, p_tags)
#   context[:product_type] = product_category(p_tags['product_type'])
#   %w[medium art_type].map{|k| attrs_case_context(context, k, p_tags[k])}
#   attrs_item_params(d_hsh, attrs, store, p_tags, context[:product_type])
# end

# def unrelated_params(f_grp)
#   store = d_hsh_loop(f_grp[:d_hsh], f_grp[:store])
#   #i_group[:attrs]
# end

# def update_tagline(store, tagline_keys)
#   reorder_keys(keys: tagline_keys, k:'signature', i:-1) if unsigned?(store)
#   paper_case(store, tagline_keys) if standard_paper?(store)
#   remove_keys(tagline_keys, 'medium') if giclee?(store) && !limited_edition?(store)
#   tagline_keys
# end
#
# def paper_case(store, tagline_keys)
#   if giclee?(store)
#     giclee_on_paper_case(store, tagline_keys)
#   elsif print?(store) || poster?(store)
#     print_on_paper_case(store, tagline_keys)
#   else
#     remove_keys(tagline_keys, 'material')
#   end
# end
#
# def giclee_on_paper_case(store, tagline_keys)
#   if signed?(store) && !embellished?(store)
#     signed_giclee_case(store, tagline_keys)
#   elsif embellished?(store) && !limited_edition?(store)
#     remove_keys(tagline_keys, 'material')
#   elsif !embellished?(store) && !limited_edition?(store)
#     remove_keys(tagline_keys, 'medium', 'material')
#   end
# end
#
# def signed_giclee_case(store, tagline_keys)
#   if limited_edition?(store)
#     remove_keys(tagline_keys, 'medium', 'material')
#     reorder_keys(keys: tagline_keys, k:'signature', ref:'edition_type')
#   else
#     remove_keys(tagline_keys, 'material')
#     reorder_keys(keys: tagline_keys, k:'signature', ref:'medium')
#   end
# end
#
# def print_on_paper_case(store, tagline_keys)
#   if signed?(store) && !embellished?(store)
#     remove_keys(tagline_keys, 'material')
#     reorder_keys(keys: tagline_keys, k:'signature', ref:'medium')
#   elsif embellished?(store)
#     remove_keys(tagline_keys, 'material')
#   elsif !signed?(store) && !embellished?(store)
#     remove_keys(tagline_keys, 'material')
#   end
# end

# def compound_kind_context_case(context)
#   context[:numbered_and_signed] = true if [:signed, :numbered].all?{|k| context[k]}
#   context[:signed_with_certificate] = true if [:signed, :certificate].all?{|k| context[k]}
#   #context[:numbered_with_certificate] = true if [:numbered, :certificate].all?{|k| context[k]}
#   #context[:signed_edition] = true if [:signed, :from_an_edition].all?{|k| context[k]}
#   #context[:signed_reproduction] = true if [:signed, :reproduction].all?{|k| context[k]}
#   context[:two_submedia] = true if [:leafing, :remarque].all?{|k| context[k]}
#   #context[:giclee_on_paper] = true if [:giclee, :paper].all?{|k| context[k]}
#   #context[:embellished_limited_edition] = true if [:limited_edition, :embellished].all?{|k| context[k]}
#   context[:unsigned] = true if !context[:signed] && !context[:missing_signature]
#   context[:shift_signature] = true if context[:missing_signature] && !context[:danger]
#   context[:skip_signature] = true if context[:unsigned] || [:missing_signature, :danger].all?{|k| context[k]}
#   context[:skip_paper] = true if context[:paper] && [:category, :embellished, :hand_pulled, :leafing, :remarque, :signed, :certificate].none?{|k| context[k]}
#   context[:remove_giclee] = true if context[:giclee] && [:category, :embellished].all?{|k| context[k]}
#   context[:reorder_signature] = true if context[:giclee] && !context[:numbered_and_signed] && !context[:signed_with_certificate]
# end

# def reorder_signature(context)
#   context[:medium] ? :medium : :category
# end

# def signed_and_numbered(context, store)
#   if [:signed, :numbered].all?{|k| context[k]}
#     puts "#{store['signature']}"
#     tagline_keys.map {|k| store['signature'][k] = "#{store['signature'][k]} and"}
#   end
# end
#
# # words= 'with ', 'and '
# def sub_media(context, store, *words)
#   if keys = [:leafing, :remarque].select{|k| context[k]}
#     keys.each_with_index {|k,i| tag_keys.map{|key| store[k][key] = words[i] + store[k][key]}}
#   end
# end
