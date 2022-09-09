require 'active_support/concern'

module Description
  extend ActiveSupport::Concern

  def description_hsh(key_group, context, d_hsh, attrs)
    admin_description_keys(context, key_group)
    set_descriptions(key_group[:skip_hsh], context, d_hsh, attrs)
  end

  ##############################################################################
  ##############################################################################

  def set_descriptions(skip_hsh, context, d_hsh, attrs)
    tb_keys.map(&:to_sym).map {|tag_key| config_description(tag_key, filter_order(context[tag_key][:order], skip_hsh[tag_key.to_s]), context, d_hsh, attrs)}
    attrs['property_room'] = config_property_room(d_hsh, d_hsh[:tagline])
  end

  def config_description(tag_key, description_keys, context, d_hsh, attrs)
    d_hsh[tag_key] = public_send("config_#{tag_key.to_s}_hsh", description_keys, tag_key.to_s, d_hsh)
    attrs[(tag_key==:body ? 'description' : tag_key.to_s)] = public_send("#{tag_key.to_s}_punct", d_hsh[tag_key], *punct_hsh(context, description_keys, tag_key).values).values.join(' ')
  end

  ##############################################################################
  def config_tagline_hsh(keys, tag_key, d_hsh)
  	keys.each_with_object({}) {|k, hsh| hsh[k]= d_hsh.dig(k, tag_key)}
  end

  def config_body_hsh(keys, tag_key, d_hsh)
  	config_tagline_hsh(keys, tag_key, d_hsh)
  end

  def config_invoice_tagline_hsh(keys, tag_key, d_hsh)
  	keys.each_with_object({}) {|k, hsh| hsh[k]= config_invoice_tagline_val(k, d_hsh.dig(k, tag_key), d_hsh)}
  end

  def config_invoice_tagline_val(k, tag_val, d_hsh, alt_key='tagline')
  	tag_val ? tag_val : abbrv_tagline_value(k, d_hsh.dig(k, alt_key))
  end

  def config_search_tagline_hsh(keys, tag_key, d_hsh)
    keys.each_with_object({}) {|k, hsh| hsh[k]= config_search_tagline_val(k, d_hsh.dig(k, tag_key), d_hsh)}
  end

  def config_search_tagline_val(k, tag_val, d_hsh, alt_key=:invoice_tagline)
  	tag_val ? tag_val : d_hsh.dig(alt_key, k)
  end
  ##############################################################################

  def abbrv_tagline_value(k, tag_val)
  	if abbrv_swap_sets = abbrv_hsh[k.to_sym]
  		Item.detect_swap(tag_val, abbrv_swap_sets)
  	else
  		tag_val
  	end
  end

  def abbrv_hsh
    {category: [['Limited Edition', 'Ltd Ed']], medium: [['Mixed Media', 'MM'], ['Hand Pulled', 'HP']]}
  end
  ##context ####################################################################
  # def filter_order(description_keys, skip_keys)
  #   description_keys.select{|k| !skip_keys.include?(k)}
  # end
  #
  # def filter_media(media_keys, description_keys)
  # 	media_keys.select{|k| description_keys.include?(k)}
  # end
  #
  # def end_punct_key(context, description_keys, tag_key, sub_key=:end_key)
  #   tag_key==:body ? context[tag_key][sub_key][-1] : description_keys[context[tag_key][sub_key].detect{|k| context[k]} ? -2 : -1]
  # end

  ###context ###################################################################
  # def admin_description_keys(context, key_group, sub_key=:order)
  #   set_media_and_end_keys(context, key_group)
  #   admin_tb_keys.map(&:to_sym).map{|tag_key| context[tag_key][sub_key] = ordered_description_keys(context, tag_key)}
  #   update_taglines_keys(context, key_group[:skip_hsh], sub_key)
  # end
  #
  # def update_taglines_keys(context, skip_hsh, sub_key, tb_key=:tagline)
  #   tb_keys[1..2].map(&:to_sym).map {|tag_key| context[tag_key] = context[tb_key]}
  #   remove_giclee_and_paper(context, skip_hsh[tb_key.to_s])
  # end
  #
  # def ordered_description_keys(context, tag_key)
  # 	ordered_keys = sorted_description_keys(context[tag_key][:order])
  # 	reorder_numbering_and_embellishing(ordered_keys, context)
  # 	reorder_signature(ordered_keys, context) if tag_key ==:tagline
  # 	ordered_keys
  # end

  ##############################################################################

  def config_property_room(descriptions_hsh, tagline_hsh)
  	['certificate', [' with ', ' w/'], 'numbered', 'numbering', [' and ', ' & '], 'artist', 'title'].each do |k|
  		property_room_case(k, descriptions_hsh, tagline_hsh)
  		property_room = tagline_hsh.values.join(' ')
  		return property_room if property_room.length<=128
  	end
  	tagline_hsh.values.join(' ')
  end

  def property_room_case(k, descriptions_hsh, tagline_hsh)
  	if k.class == Array
  		tagline_hsh.transform_values!{|v| v.sub(*k)}
  	elsif k == 'numbered'
  		tagline_hsh['numbering'] = descriptions_hsh[:search_tagline]['numbering']
  	elsif %w[certificate numbering].include?(k)
  		tagline_hsh[k] = descriptions_hsh[:invoice_tagline][k]
  	elsif k == 'title'
  		tagline_hsh.delete(k)
  	end
  end

  ##context ####################################################################
  # def remove_giclee_and_paper(context, remove)
  #   [{:giclee=> 'medium'}, {:paper=> 'material'}].map {|hsh| hsh.each {|key, kind| remove << remove_kind(context, key, kind) if context[key]}}
  # end
  #
  # def remove_kind(context, key, kind)
  # 	kind if public_send("remove_#{key.to_s}?", context)
  # end
  #
  # def remove_paper?(context)
  # 	[:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
  # end
  #
  # def remove_giclee?(context)
  # 	context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper]
  # end
  ##############################################################################

  ##############################################################################

  # def join_title(body,k)
  #   body[k] = ['is', Item.indefinite_article(body[k]), body[k]].join(' ')
  # end
  #
  # ##############################################################################
  # def tagline_punct(tagline_hsh, media_key, end_key, punct=',')
  #   tagline_hsh[media_key] = tagline_hsh[media_key]+punct if media_key != end_key && tagline_hsh[media_key][-1] != punct
  #   tagline_hsh
  # end
  #
  # def body_punct(body_hsh, media_key, end_key, title_key)
  # 	join_title(body_hsh, title_key)
  # 	body_hsh[end_key] = body_hsh[end_key]+'.' if body_hsh[end_key]
  # 	body_hsh[media_key] = body_hsh[media_key]+(body_hsh[end_key] ? ',' : '.')
  # 	body_hsh
  # end
  #
  # def invoice_tagline_punct(tagline_hsh, media_key, end_key)
  # 	tagline_punct(tagline_hsh, media_key, end_key)
  # end
  #
  # def search_tagline_punct(tagline_hsh, media_key, end_key)
  #   tagline_punct(tagline_hsh, media_key, end_key)
  # end

  ##context ####################################################################

  # def reorder_numbering_and_embellishing(ordered_keys, context)
  # 	if args = reorder_args(context)
  # 		reorder_keys({keys: ordered_keys}.merge!(args))
  # 	end
  # end
  #
  # def reorder_args(context)
  # 	if context[:proof_edition]
  # 		reorder_proof_edition
  # 	elsif !context[:numbering] && context[:embellishing_category]
  # 		reorder_medium
  # 	end
  # end
  #
  # def reorder_signature(ordered_keys, context)
  #   return unless context[:signature]
  #   if context[:signature_last]
  #     reorder_keys(keys: ordered_keys, k: 'signature', i: -1)
  #   elsif ref_key = signature_ref_key(ordered_keys, context)
  #     reorder_keys(keys: ordered_keys, k: 'signature', ref: ref_key)
  #   end
  # end
  #
  # def signature_ref_key(ordered_keys, context)
  #   if [:category, :certificate].none?{|k| ordered_keys.include?(k)} || [:numbered, :certificate].none?{|k| ordered_keys.include?(k)}
  #     'medium'
  #   elsif context[:proof_edition] && !context[:certificate]
  #     !context[:embellishing] ? 'category' : 'embellishing'
  #   end
  # end
  #
  # def signature_params(context, store, v, k, tag_key)
  #   v = gartner_blade_signature(v, tag_key) if context[:gartner_blade] && !context[:unsigned]
  #   Item.case_merge(store, v, k, tag_key)
  # end
  #
  # def gartner_blade_signature(v, tag_key)
  #   v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : "This piece is hand signed by GartnerBlade Glass.")
  # end

  def field_context_order(k, tb_hsh, context)
  	admin_tb_keys.select {|tag_key| tb_hsh[tag_key]}.map{|tag_key| set_order(context, tag_key.to_sym, k)}
  end

  def set_order(context, tag_key, k, sub_key=:order)
    Item.case_merge(context, key_group[tag_key][sub_key].index(k), tag_key, sub_key, k)
  end

  # def config_compound_kinds(context)
  #   compound_kind_context.map{|kinds| compound_keys(context, kinds)}
  # end

  ##context ####################################################################
  # def reorder_proof_edition
  #   {k: 'numbering', ref: 'medium', i: 1}
  # end
  #
  # def reorder_medium
  #   {k: 'embellishing', ref: 'medium'}
  # end

  def context_from_selected(k, t, f_name, selected, context)
  	if valid_tag_attr?(k, selected)
  		config_tag_attr_context(k, selected, context)
  	elsif tag_hsh = valid_option?(k, selected)
  		config_option_context(k, f_name, tag_hsh, context)
  	end
  end

  def valid_tag_attr?(k, selected)
  	selected.class == String && %w[dated verification disclaimer].include?(k)
  end

  def valid_option?(k, selected)
    selected.tags if selected.class==Option && selected.tags
  end

  def config_option_context(k, f_name, tag_hsh, context)
  	set_option_kind_context(k, context)
  	set_numbering_context(k, f_name, context)
  	set_tagline_value_context(k, tag_hsh, context)
  	field_context_order(k, tag_hsh, context)
  end

  def set_option_kind_context(k, context)
  	context[k.to_sym] = true if valid_option_kind?(k)
  end

  def valid_option_kind?(k)
  	%w[embellishing category medium sculpture_type numbering leafing remarque animator_seal sports_seal certificate].include?(k)
  end

  def config_tag_attr_context(k, selected, context)
  	context[k.to_sym] = true
  	set_order(context, :body, k)
  end

  def set_kind_context(k, selected, context)
    context[k.to_sym] = true if valid_kind_context?(k, selected)
  end

  def set_numbering_context(k, f_name, context)
    context[f_name.to_sym] = true if valid_numbering_context?(k, f_name)
  end

  def set_tagline_value_context(k, tag_hsh, context)
    if value_set = get_tagline_value_context(k, tag_hsh)
      context[symbolize(value_set[-1])] = true
    end
  end

  def valid_numbering_context?(k, f_name)
    k=='numbering' && %w[proof_edition numbered].include?(f_name)
  end

  def get_tagline_value_context(k, tag_hsh, tag_key='tagline')
    key_group.dig(tag_key.to_sym, k.to_sym).detect{|set| tag_hsh.dig(tag_key).index(set[0])} if valid_tagline_value?(k, tag_hsh, tag_key)
  end

  def valid_tagline_val?(v, tagline_vals)
    if set = tagline_vals.detect{|set| v.index(set[0])}
      symbolize(set[-1])
    end
  end

  def valid_tagline_value?(k, tag_hsh, tag_key)
    tag_hsh.dig(tag_key) && key_group.dig(tag_key.to_sym, k.to_sym)
  end

  ##############################################################################

  # def contexts
  #   {
  #     title_keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature certificate disclaimer],
  #     body_keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
  #     skip_hsh: {'tagline'=> [], 'invoice_tagline'=> %w[mounting disclaimer], 'search_tagline'=> %w[artist title mounting dimension disclaimer], 'body'=>[]},
  #     dependent_kinds: {
  #       LimitedEdition: ['numbering'], Dimension: ['dimension'], Disclaimer: ['disclaimer'], Authentication: %w[certificate dated verification animator_seal sports_seal], Submedium: %w[embellishing leafing remarque]
  #     },
  #     gartner_blade: %w[category text_after_title sculpture_type sculpture_part signature dimension disclaimer],
  #
  #     tagline: {
  #       category: [['Limited Edition']], medium: [['Giclee'], ['Hand Pulled'], ['Mixed Media']], material: [['Gallery Wrapped'], ['Rice'], ['Paper']], mounting: [['Framed']], signature: [['Unsigned'], ['Plate Signed', 'Signed'], ['Signed'], ['Signature', 'Signed']], disclaimer: [['Disclaimer', 'Danger']],
  #       media: %w[category medium sculpture_type material leafing remarque dimension],
  #       authentication: [:disclaimer, :unsigned]
  #     },
  #
  #     abbrv: {
  #       category: [['Limited Edition', 'Ltd Ed']], medium: [['Mixed Media', 'MM'], ['Hand Pulled', 'HP']]
  #     },
  #     body: {
  #       media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
  #       authentication: %w[dated numbering signature]
  #     },
  #     csv: {
  #       export: %w[sku artist artist_id title retail width height frame_width frame_height tagline property_room description art_type art_category material medium qty],
  #       item_product: %w[title width height frame_width frame_height tagline description tagline_search invoice_tagline mounting_search measurements item_size]
  #     }
  #   }
  # end

  def transform_params(params, conj, push=nil)
  	params.transform_values!{|tag_val| push ? "#{tag_val} #{conj}" : "#{conj} #{tag_val}"}
  end
end

# def config_description_hsh(context, d_hsh)
#   description_keys(context, key_group[:skip_hsh]).each_with_object({}) do |(tag_key, kind_order), hsh|
#     kind_order.map {|k| update_description_value(context, k, tag_key, d_hsh.dig(k, tag_key), hsh)}
#   end
# end

# def description_keys(context, skip_hsh)
#   context[:order].each_with_object({}) {|(tag_key, v_hsh), hsh| config_description_keys(tag_key, v_hsh.sort_by{|k,v| v}.to_h.keys, context, skip_hsh, hsh)}
# end
#
# def config_description_keys(tag_key, keys, context, skip_hsh, hsh)
#   reorder_numbering_and_embellishing(keys, context)
#   tag_key=='tagline' ? config_title_keys(keys, context, tag_key, skip_hsh, hsh) : hsh[tag_key] = keys
# end

# def config_title_keys(keys, context, tag_key, hsh)
#   reorder_signature(keys, context)
#   hsh[tag_key] = keys.select{|k| skip_keys(context).exclude?(k)}
#   %w[invoice_tagline search_tagline].map{|key| hsh[key] = keys.select{|k| key_group[:skip_hsh][key].exclude?(k)}}
# end

# def update_description_value(context, k, tag_key, tag_val, hsh)
#   if tag_val = config_description_value(context, k, tag_key, tag_val, hsh)
#     Item.case_merge(hsh, tag_val, tag_key, k)
#   end
# end

# def config_description_value(context, k, tag_key, tag_val, hsh)
# 	return tag_val if tag_val && (tag_key=='body' || tag_key=='tagline')
# 	if tag_key=='invoice_tagline'
# 		config_invoice_tagline_value(hsh, k, tag_val)
# 	elsif tag_key=='search_tagline'
# 		config_search_tagline_value(hsh, k, tag_val)
# 	end
# end
#
# def config_invoice_tagline_value(hsh, k, tag_val)
# 	return tag_val if tag_val
# 	if tag_val = hsh.dig('tagline', k)
# 		abbrv_tagline_value(k, tag_val)
# 	end
# end
#

#
# def config_search_tagline_value(hsh, k, tag_val)
# 	return tag_val if tag_val
# 	if tag_val = hsh.dig('invoice_tagline', k)
# 		tag_val
# 	end
# end

# def tagline_punct(context, tagline, keys)
# 	tagline_end, media_end = keys[(rev_detect([:disclaimer, :unsigned], keys) ? -2 : -1)], rev_detect(contexts[:tagline][:media], keys)
# 	#tagline[tagline_end] = tagline[tagline_end]+'.'
# 	tagline[media_end] = tagline[media_end]+',' if media_end != tagline_end
# 	tagline
# end

# def body_punct(context, tag_hsh, keys)
#   join_title(tag_hsh, keys[keys.index('title')+1])
# 	body_end, media_end = rev_detect(contexts[:body][:authentication].reject{|k| k == 'numbering' && context[:proof_edition]}, keys),  rev_detect(contexts[:body][:media], keys)
# 	tag_hsh[body_end] = tag_hsh[body_end]+'.' if body_end
# 	tag_hsh[media_end] = tag_hsh[media_end]+(body_end ? ',' : '.')
# 	tag_hsh
# end

# def reordered_keys(ordered_keys, context)
#   reorder_keys(keys: ordered_keys, k: 'numbering', ref: 'medium', i: 1) if context[:proof_edition]
#   reorder_keys(keys: ordered_keys, k: 'embellishing', ref: 'medium') if !context[:numbering] && context[:embellishing_category]
# end

# def skip_keys(context, skip=[])
#   skip.append('material') if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
#   skip.append('medium') if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
#   skip
# end

# def config_invoice_tagline(context, title)
#   invoice_tagline = filtered_params(title, title.keys.select{|k| %w[mounting disclaimer].exclude?(k)}, 'invoice_tagline', 'tagline')
#   invoice_tagline = tagline_punct(context, invoice_tagline, invoice_tagline.keys)
#   Item.char_limit(invoice_tagline, contexts[:invoice_tagline][:set], 140)
# end
#
# def config_search_tagline(context, title)
#   search_tagline = filtered_params(title, title.keys.select{|k| %w[artist title mounting dimension disclaimer].exclude?(k)}, 'search_tagline', 'tagline')
#   search_tagline = tagline_punct(context, search_tagline, search_tagline.keys)
#   Item.char_limit(search_tagline, contexts[:search_tagline][:set], 115)
# end


# def order_description_keys(ordered_keys, context, d_hsh, description_key)
#   ordered_keys = ordered_keys.each_with_object([]) {|k, keys| keys.append(k) if d_hsh.dig(k, description_key)}
#   reordered_keys(ordered_keys, context)
#   ordered_keys
# end

# def title_keys(ordered_keys, context, d_hsh, description_key='tagline')
#   title_keys = order_description_keys(ordered_keys, context, d_hsh, description_key)
#   reorder_signature(title_keys, context) if context[:signature]
#   title_keys
# end

# def remove_tagline_keys(ordered_keys, context)
#   remove_key(ordered_keys, 'material') if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
#   remove_key(ordered_keys, 'medium') if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
# end
#
# def skip_tagline_key(kind, context)
#   (kind=='material' && context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|key| context[key]}) || (kind=='medium' && context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper]))
# end

# def description_hsh(tag_key, keys, store)
#   keys.each_with_object({}) do |k,h|
#     if v = store.dig(k, tag_key)
#       h[k] = v
#     end
#   end
# end

# def description_keys(context, title_keys, body_keys)
#   [title_keys, body_keys].map{|keys| reordered_keys(keys, context)}
#   reorder_signature(title_keys, context)
#   {'tagline'=>title_keys.select{|k| skip_keys(context).exclude?(k)}, 'invoice_tagline'=>title_keys, 'search_tagline'=>title_keys, 'body'=>body_keys}
# end
#
# def config_description_hsh(context, d_hsh)
# 	d_hsh.each_with_object({}) do |(k, tb_hsh), hsh|
# 		order_hsh(tb_keys, tb_hsh).each do |tag_key, tag_val|
# 			next if contexts[:skip_hsh][tag_key].include?(k)
# 			if tag_val = config_description_value(context, k, tag_key, tag_val, hsh)
#         Item.case_merge(hsh, tag_val, tag_key, k)
# 			end
# 		end
# 	end
# end

# def context_from_selected(k, t, f_name, selected, context)
# 	context[k.to_sym] = true if contexts[:present_keys].include?(k)
#   context[:valid] = true if %w[medium sculpture_type].include?(k)
# 	LimitedEdition.numbering_context(f_name, context) if k == 'numbering'
# 	return if tag_attr?(t) || selected.tags.blank?
# 	if tag_val = selected.tags.dig('tagline')
# 		set_tagline_vals_context(k, tag_val, context)
# 	end
# end

# def config_context(context_hsh, k, sub_key=:order)
# 	%w[tagline body].each do |tag_key|
# 		if idx = contexts["#{tag_key}_keys".to_sym].index(k)
# 			Item.case_merge(context_hsh, sub_key, k, idx, tag_key)
# 		end
# 	end
# end

# def klass_for_compound_kind(k)
#   case
#     when %w[disclaimer].include?(k); to_class(k)
#     when %w[certificate dated verification].include?(k); Authentication
#     when k=='numbering'; LimitedEdition
#   end
# end
