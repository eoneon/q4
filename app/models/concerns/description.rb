require 'active_support/concern'

module Description
  extend ActiveSupport::Concern

  def description_hsh(key_group, context, d_hsh, attrs)
    admin_description_keys(context, key_group)
    set_descriptions(key_group[:skip_hsh], context, d_hsh, attrs)
  end

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
  	keys.append('dimension').each_with_object({}) {|k, hsh| hsh[k]= config_invoice_tagline_val(k, d_hsh.dig(k, tag_key), d_hsh)}
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
  		tagline_hsh.transform_values!{|v| v.sub(*k) if v}
  	elsif k == 'numbered'
  		tagline_hsh['numbering'] = descriptions_hsh[:search_tagline]['numbering']
  	elsif %w[certificate numbering].include?(k)
  		tagline_hsh[k] = descriptions_hsh[:invoice_tagline][k]
  	elsif k == 'title'
  		tagline_hsh.delete(k)
  	end
  end

  def field_context_order(k, tb_hsh, context)
  	admin_tb_keys.select {|tag_key| tb_hsh[tag_key]}.map{|tag_key| set_order(context, tag_key.to_sym, k)}
  end

  def set_order(context, tag_key, k, sub_key=:order)
    Item.case_merge(context, key_group[tag_key][sub_key].index(k), tag_key, sub_key, k)
  end

  def context_from_selected(k, t, f_name, selected, context)
  	if tag_hsh = valid_option?(k, selected)
  		config_option_context(k, f_name, tag_hsh, context)
  	end
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
  	set_context(k, context) if valid_option_kind?(k)
  	set_context(:seal, context) if k=='animator_seal' || k=='sports_seal'
  end

  def set_context(k, context)
  	context[k.to_sym] = true
  end

  def valid_option_kind?(k)
  	%w[embellishing category medium sculpture_type numbering leafing remarque seal animator_seal sports_seal certificate].include?(k)
  end

  def config_tag_attr_context(k, selected, context)
  	context[k.to_sym] = true
  	set_order(context, :body, k)
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

  def transform_params(params, conj, push=nil)
  	params.transform_values!{|tag_val| push ? "#{tag_val} #{conj}" : "#{conj} #{tag_val}"}
  end
end

# def context_from_selected(k, t, f_name, selected, context)
# 	if valid_tag_attr?(k, selected)
# 		config_tag_attr_context(k, selected, context)
# 	elsif tag_hsh = valid_option?(k, selected)
# 		config_option_context(k, f_name, tag_hsh, context)
# 	end
# end

# def valid_tag_attr?(k, selected)
# 	selected.class == String && %w[dated verification disclaimer].include?(k)
# end
