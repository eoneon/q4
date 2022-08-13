require 'active_support/concern'

module Description
  extend ActiveSupport::Concern

  # def config_descriptions(context, keys_hsh, d_hsh, attrs)
  # 	config_description_hsh(context, d_hsh).each do |tag_key, tag_hsh|
  #     config_description(context, tag_key, order_valid_hsh(keys_hsh[tag_key], tag_hsh), d_hsh, attrs)
  # 	end
  #   attrs
  # end

  def config_descriptions(context, d_hsh, attrs)
    config_description_hsh(context, d_hsh).each do |tag_key, tag_hsh|
      config_description(context, tag_key, tag_hsh, d_hsh, attrs)
    end
  end

  def config_description(context, tag_key, tag_hsh, d_hsh, attrs)
    public_send("#{tag_key}_punct", context, tag_hsh, tag_hsh.keys)
    attrs[(tag_key=='body' ? 'description' : tag_key)] = build_description(tag_key, tag_hsh)
    attrs['property_room'] = config_property_room(context, d_hsh, tag_hsh) if tag_key =='tagline'
  end

  def build_description(tag_key, tag_hsh)
    %w[tagline body].include?(tag_key) ? tag_hsh.values.join(' ') : Item.inject_swap(tag_hsh.values.join(' '), [[' with ', ' w/'], [' and ', ' & ']])
  end

  #1 ###########################################################################
  def config_description_hsh(context, d_hsh)
  	description_keys(context).each_with_object({}) do |(tag_key, kind_order), hsh|
  		kind_order.map {|k| update_description_value(context, k, tag_key, d_hsh.dig(k, tag_key), hsh)}
  	end
  end

  def description_keys(context)
    context[:order].each_with_object({}) {|(tag_key, v_hsh), hsh| config_description_keys(tag_key, v_hsh.sort_by{|k,v| v}.to_h.keys, context, hsh)}
  end

  def config_description_keys(tag_key, keys, context, hsh)
    reordered_keys(keys, context)
    tag_key=='tagline' ? config_title_keys(keys, context, tag_key, hsh) : hsh[tag_key] = keys
  end

  def config_title_keys(keys, context, tag_key, hsh)
    reorder_signature(keys, context)
    hsh[tag_key] = keys.select{|k| skip_keys(context).exclude?(k)}
    %w[invoice_tagline search_tagline].map{|key| hsh[key] = keys.select{|k| contexts[:skip_hsh][key].exclude?(k)}}
  end

  def update_description_value(context, k, tag_key, tag_val, hsh)
    if tag_val = config_description_value(context, k, tag_key, tag_val, hsh)
      Item.case_merge(hsh, tag_val, tag_key, k)
    end
  end
  ###########################################################################

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

  def config_description_value(context, k, tag_key, tag_val, hsh)
  	return tag_val if tag_val && (tag_key=='body' || tag_key=='tagline')
  	if tag_key=='invoice_tagline'
  		config_invoice_tagline_value(hsh, k, tag_val)
  	elsif tag_key=='search_tagline'
  		config_search_tagline_value(hsh, k, tag_val)
  	end
  end

  def config_invoice_tagline_value(hsh, k, tag_val)
  	return tag_val if tag_val
  	if tag_val = hsh.dig('tagline', k)
  		abbrv_tagline_value(k, tag_val)
  	end
  end

  def abbrv_tagline_value(k, tag_val)
  	if abbrv_swap_sets = contexts[:abbrv][k.to_sym]
  		Item.detect_swap(tag_val, abbrv_swap_sets)
  	else
  		tag_val
  	end
  end

  def config_search_tagline_value(hsh, k, tag_val)
  	return tag_val if tag_val
  	if tag_val = hsh.dig('invoice_tagline', k)
  		tag_val
  	end
  end

  def config_property_room(context, d_hsh, tagline_hsh)
  	['certificate', [' with ', ' w/'], 'numbered', 'numbering', [' and ', ' & '], 'artist', 'title'].each do |k|
  		property_room_case(context, k, d_hsh, tagline_hsh)
  		property_room = tagline_hsh.values.join(' ')
  		return property_room if property_room.length<=128
  	end
    tagline_hsh.values.join(' ')
  end

  def property_room_case(context, k, d_hsh, tagline_hsh)
  	if k.is_a? Array
      tagline_hsh.transform_values!{|v| v.sub(*k)}
  	elsif k == 'numbered'
  		tagline_hsh['numbering'] = d_hsh['numbering']['search_tagline']
    elsif context[k.to_sym]
      tagline_hsh[k] = d_hsh[k]['invoice_tagline']
  	elsif k == 'title'
  		tagline_hsh.delete(k)
  	end
  end

  ##############################################################################

  def join_title(body,k)
    body[k] = ['is', Item.indefinite_article(body[k]), body[k]].join(' ')
  end

  ##############################################################################
  def tagline_punct(context, tagline, keys)
  	tagline_end, media_end = keys[(rev_detect([:disclaimer, :unsigned], keys) ? -2 : -1)], rev_detect(contexts[:tagline][:media], keys)
  	#tagline[tagline_end] = tagline[tagline_end]+'.'
  	tagline[media_end] = tagline[media_end]+',' if media_end != tagline_end
  	tagline
  end

  def invoice_tagline_punct(context, tagline, keys)
  	tagline_punct(context, tagline, keys)
  end

  def search_tagline_punct(context, tagline, keys)
    tagline_punct(context, tagline, keys)
  end

  def body_punct(context, tag_hsh, keys)
    join_title(tag_hsh, keys[keys.index('title')+1])
  	body_end, media_end = rev_detect(contexts[:body][:authentication].reject{|k| k == 'numbering' && context[:proof_edition]}, keys),  rev_detect(contexts[:body][:media], keys)
  	tag_hsh[body_end] = tag_hsh[body_end]+'.' if body_end
  	tag_hsh[media_end] = tag_hsh[media_end]+(body_end ? ',' : '.')
  	tag_hsh
  end
  ##############################################################################

  def reordered_keys(ordered_keys, context)
    reorder_keys(keys: ordered_keys, k: 'numbering', ref: 'medium', i: 1) if context[:proof_edition]
    reorder_keys(keys: ordered_keys, k: 'embellishing', ref: 'medium') if !context[:numbering] && context[:embellishing_category]
  end

  def reorder_signature(ordered_keys, context)
    return unless context[:signature]
    if context[:signature_last]
      reorder_keys(keys: ordered_keys, k: 'signature', i: -1)
    elsif ref_key = signature_ref_key(ordered_keys, context)
      reorder_keys(keys: ordered_keys, k: 'signature', ref: ref_key)
    end
  end

  def signature_ref_key(ordered_keys, context)
    if [:category, :certificate].none?{|k| ordered_keys.include?(k)} || [:numbered, :certificate].none?{|k| ordered_keys.include?(k)}
      'medium'
    elsif context[:proof_edition] && !context[:certificate]
      !context[:embellishing] ? 'category' : 'embellishing'
    end
  end

  def skip_keys(context, skip=[])
    skip.append('material') if context[:paper] && [:category, :embellishing, :leafing, :remarque, :signature].any?{|k| context[k]}
    skip.append('medium') if context[:giclee] && (context[:proof_edition] || context[:numbered] && context[:embellishing] || !context[:paper])
    skip
  end

  def signature_params(context, store, v, k, tag_key)
    v = gartner_blade_signature(v, tag_key) if context[:gartner_blade] && !context[:unsigned]
    Item.case_merge(store, v, k, tag_key)
  end

  def gartner_blade_signature(v, tag_key)
    v = (tag_key == 'tagline' ? "#{v} by GartnerBlade Glass." : "This piece is hand signed by GartnerBlade Glass.")
  end

  # def context_from_selected(k, t, f_name, selected, context)
  # 	LimitedEdition.numbering_context(k, f_name, context) if k == 'numbering'
  #   valid_tag_attr_context(context, k)
  # 	return if tag_attr?(t) || selected.tags.blank?
  # 	config_order(context, k)
  #   config_tagline_context(context, k, selected)
  # end

  # def context_from_selected(k, t, f_name, selected, context)
  #   return if (tag_attr?(t) && !valid_tag_attr_context?(k)) || selected.tags.blank?
  #   set_context(t, k) if !context[k.to_sym]
  #   config_order(context, k)
  #   config_tagline_context(context, k, selected)
  # end

  # def context_from_selected(k, t, f_name, selected, context)
  #   return if (tag_attr?(t) && !valid_tag_attr_context?(k)) || (!tag_attr?(t) && selected.tags.blank?)
  #   set_context(t, k, f_name, context)
  #   config_order(context, k)
  #   config_tagline_context(context, k, selected) unless tag_attr?(t)
  # end

  def context_from_selected(k, t, f_name, selected, context)
  	if tag_attr?(t)
  		tag_attr_context(k, context)
  	elsif !selected.tags.blank?
  		field_context(k, f_name, selected, context)
      config_tagline_context(context, k, selected)
  	end
  end

  def tag_attr_context(k, context)
  	if valid_tag_attr_context?(k)
  		context[k.to_sym] = true
  		config_order(context, k)
  	end
  end

  def field_context(k, f_name, selected, context)
  	if key = field_context_key(k, f_name)
  		context[key.to_sym] = true
  		config_order(context, k)
  	end
  end

  def field_context_key(k, f_name)
  	if valid_numbering?(f_name)
  		f_name
  	elsif present_context?(k)
  		k
  	end
  end
  # def set_context(t, k, f_name, context)
  #   if key = get_context_key(t, k, f_name)
  #     context[key.to_sym] = true
  #   end
  # end
  #
  # def get_context_key(t, k, f_name)
  #    if (tag_attr?(t) || present_context?(k))
  #      k
  #    elsif valid_numbering?(f_name)
  #      f_name
  #    end
  # end
  def dependend_kinds_hsh(keys)
  	dependent_kinds.each_with_object({}) {|(klass, kinds), h| h[klass] = kinds.reject{|k| keys.exclude?(k)}}.reject{|klass, kinds| kinds.empty?}
  end

  def config_compound_kinds(context)
    compound_kind_context.map{|kinds| compound_keys(context, kinds)}
  end

  def valid_tag_attr_context?(k)
    %w[dated verification disclaimer].include?(k)
  end

  def valid_numbering?(f_name)
    %w[proof_edition numbered].include?(f_name)
  end

  def present_context?(k)
    %w[embellishing category medium sculpture_type numbering leafing remarque certificate].include?(k)
  end

  def compound_kind_context
    [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate], [:disclaimer, :danger]]
  end

  def dependent_kinds
    {LimitedEdition: ['numbering'], Disclaimer: ['disclaimer'], Authentication: %w[certificate dated verification animator_seal sports_seal], Submedium: %w[leafing remarque]}
  end

  def config_tagline_context(context, k, selected, tag_key='tagline')
    if tag_val = selected.tags.dig(tag_key)
      set_tagline_vals_context(k, tag_val, context)
    end
  end

  def config_order(context, k, sub_key=:order)
    %w[title body].each do |tag_key|
      idx = contexts["#{tag_key}_keys".to_sym].index(k)
      Item.case_merge(context, idx, sub_key, (tag_key=='title' ? 'tagline' : tag_key), k)
    end
  end

  def final_context(context)
    config_compound_kinds(context)
    description_keys(context)
  end
  # def context_from_selected(k, t, f_name, selected, context)
  # 	context[k.to_sym] = true if contexts[:present_keys].include?(k)
  #   context[:valid] = true if %w[medium sculpture_type].include?(k)
  # 	LimitedEdition.numbering_context(f_name, context) if k == 'numbering'
  # 	return if tag_attr?(t) || selected.tags.blank?
  # 	if tag_val = selected.tags.dig('tagline')
  # 		set_tagline_vals_context(k, tag_val, context)
  # 	end
  # end

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

  def compound_keys(context, keys)
    context[keys.map(&:to_s).join('_').to_sym] = true if keys.all?{|k| context[k]}
  end

  def product_type
    {
      compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate]],
      category: [['Limited Edition']], medium: [['Giclee'],['Hand Pulled']], material: [['Gallery Wrapped'], ['Rice'], ['Paper']], mounting: [['Framed']], signature: [['Unsigned'],['Plate Signed', 'Signed'],['Signed'],['Signature', 'Signed']], disclaimer: [['Disclaimer']],
      csv: {
        export: %w[sku artist artist_id title retail width height frame_width frame_height tagline property_room description art_type art_category material medium qty],
        item_product: %w[title width height frame_width frame_height tagline description tagline_search invoice_tagline mounting_search measurements item_size]
      },

      flat_art: {
        present_keys: %w[embellishing category medium material numbering leafing remarque date seal animator_seal sports_seal certificate],
        tagline: {
          order: %w[artist title mounting embellishing category medium material dimension leafing remarque numbering signature animator_seal sports_seal certificate disclaimer],
          punct: {
            media: %w[category medium sculpture_type material leafing remarque dimension],
            end_key: %w[disclaimer unsigned]
          }
        },

        body: {
          order: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
          punct: {
            media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
            end_key: %w[dated numbering signature]
          }
        }
      }
    }
  end

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

  def contexts
    {
      #present_keys: %w[embellishing category medium sculpture_type leafing remarque certificate],
      title_keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature certificate disclaimer],
      body_keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
      skip_hsh: {'tagline'=> [], 'invoice_tagline'=> %w[mounting disclaimer], 'search_tagline'=> %w[artist title mounting dimension disclaimer], 'body'=>[]},
      dependent_kinds: {
        LimitedEdition: ['numbering'], Dimension: ['dimension'], Disclaimer: ['disclaimer'], Authentication: %w[certificate dated verification animator_seal sports_seal], Submedium: %w[embellishing leafing remarque]
      },
      #compound_kinds: [[:embellishing, :category], [:leafing, :remarque], [:numbered, :signed], [:animator_seal, :sports_seal], [:seal, :certificate], [:disclaimer, :danger]],
      gartner_blade: %w[category text_after_title sculpture_type sculpture_part signature dimension disclaimer],

      tagline: {
        #keys: %w[artist title mounting embellishing category medium sculpture_type material dimension leafing remarque numbering signature certificate disclaimer],
        category: [['Limited Edition']], medium: [['Giclee'], ['Hand Pulled'], ['Mixed Media']], material: [['Gallery Wrapped'], ['Rice'], ['Paper']], mounting: [['Framed']], signature: [['Unsigned'], ['Plate Signed', 'Signed'], ['Signed'], ['Signature', 'Signed']], disclaimer: [['Disclaimer', 'Danger']],
        #vals: [['Limited Edition'], ['Giclee'], ['Mixed Media'], ['Hand Pulled'], ['Unsigned'],['Plate Signed', 'Signed'],['Signed'],['Signature', 'Signed'],['Disclaimer']], #['Gallery Wrapped'],['Paper'],
        media: %w[category medium sculpture_type material leafing remarque dimension],
        authentication: [:disclaimer, :unsigned]
      },

      abbrv: {
        category: [['Limited Edition', 'Ltd Ed']], medium: [['Mixed Media', 'MM'], ['Hand Pulled', 'HP']]
      },
      body: {
        #keys: %w[title text_after_title embellishing category medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting animator_seal sports_seal certificate dimension disclaimer],
        media: %w[text_after_title category numbering medium sculpture_type material leafing remarque artist],
        authentication: %w[dated numbering signature]
      },
      csv: {
        export: %w[sku artist artist_id title retail width height frame_width frame_height tagline property_room description art_type art_category material medium qty],
        item_product: %w[title width height frame_width frame_height tagline description tagline_search invoice_tagline mounting_search measurements item_size]
      }
    }
  end

  def transform_params(params, conj, push=nil)
  	params.transform_values!{|tag_val| push ? "#{tag_val} #{conj}" : "#{conj} #{tag_val}"}
  end
end

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
