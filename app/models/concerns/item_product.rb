require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern

  def form_and_data(action:nil)
  	if p = product
  		show_or_update(action, config_item_product(p.tags, p.unpacked_fields, init_input_group))
  	else
  		[[], {}]
  	end
  end

  def show_or_update(action, input_group)
  	if action == 'show'
  		input_group[:rows]
  	else
  		rows_and_attrs(input_group)
  	end
  end

  def rows_and_attrs(input_group)
  	description_hsh(key_group, input_group[:context], input_group[:d_hsh], input_group[:attrs])
    [:rows, :attrs].map{|k| input_group[k]}
  end

  def config_item_product(p_tags, p_fields, input_group)
  	item_product_attrs(p_tags, input_group[:d_hsh], input_group[:context], input_group[:attrs])
    config_group(fields: p_fields, input_group: input_group)
  	config_form_group(input_group, p_tags)
  	input_group
  end

  def item_product_attrs(p_tags, d_hsh, context, attrs)
  	config_attrs(p_tags, attrs)
  	artist_params(context, attrs, d_hsh)
  	title_params(context, attrs, d_hsh)
  end

  ##############################################################################

  def config_group(fields:nil, input_group:nil)
  	config_loop(fields: fields, input_group: input_group)
  	config_conditional_kinds(input_group, input_group[:context], input_group[:d_hsh])
  	set_compound_keys(input_group[:context])
  	config_compound_kinds(input_group, input_group[:context], input_group[:d_hsh])
  end

  def config_loop(fields:nil, input_group:nil)
    fields.each_with_object(input_group) do |f, input_group|
      tb_tags_from_field(input_group[:d_hsh], f, f.kind.underscore)
      description_field_case(*f.fattrs, f, input_group)
    end
  end

  def description_field_case(k, t, f_name, f, input_group)
  	if field_set?(t)
  		config_loop(fields: f.fieldables, input_group: input_group)
  	elsif !no_assocs?(t)
  		push_input_and_config_selected(k, t, f_name, f, input_group)
    elsif tags_hsh = f.tags
      field_context_order(k, tags_hsh, input_group[:context])
  	end
  end

  def push_input_and_config_selected(k, t, f_name, f, input_group)
  	input_group[:inputs] << f_hsh(k, t, f_name, f)
  	if selected = input_group[:param_hsh].dig(k, t_type(t), f_name)
  		input_group[:inputs][-1][:selected] = format_selected(t, selected)
  		config_selected(reset_kind(k, f_name), t, f_name, selected, input_group)
  	end
  end

  def config_selected(k, t, f_name, selected, input_group)
  	context_from_selected(k, t, f_name, selected, input_group[:context])
    tag_attr?(t) ? selected_tag_attr(input_group[:d_hsh], selected, k, f_name) : selected_field(input_group, selected, k)
  end

  def selected_tag_attr(d_hsh, selected, k, f_name)
  	k=='dimension' ? Dimension.measurement_hsh(d_hsh, selected, k, f_name) : Item.case_merge(d_hsh, selected, k, f_name)
  end

  def reset_kind(k, f_name)
    k=='seal' ? f_name : k
  end

  ###################################################################
  def selected_field(input_group, selected, k)
    tags_from_selected_fields(input_group, selected, k) if selected.tags && selected.tags.any?
    config_loop(fields: selected.fieldables, input_group: input_group) if field_set?(selected.type)
  end

  ###################################################################
  ###################################################################
  def tags_from_selected_fields(input_group, f, k)
  	tags_from_related_fields(input_group, f, k)
  	tb_tags_from_field(input_group[:d_hsh], f, k) unless k=='dimension'
  end

  def tags_from_related_fields(input_group, f, k)
  	if args = related_param_args(k)
  		f.to_class(k).merge_related_params(input_group, f, args)
  	end
  end

  def related_param_args(k)
  	{'dimension'=> [k, 'material_dimension', 'tag'], 'material'=> ['mounting', 'material_mounting', 'body'], 'mounting'=> ['dimension', 'mounting_dimension', 'tag']}[k]
  end
  ###################################################################
  ###################################################################

  def tb_tags_from_field(d_hsh, f, k)
    tb_keys.map {|tag_key| Item.case_merge(d_hsh, f.tags[tag_key], k, tag_key)} if f.tags && f.tags.any?
  end

  ###################################################################

  def format_selected(t, selected)
    tag_attr?(t) ? selected : selected.id
  end

  def config_attrs(p_tags, attrs)
    attrs.merge!(default_hsh(*csv_export_attrs))
  	%w[sku retail qty].map{|k| attrs[k] = public_send(k)}
  	Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
  end

  ##############################################################################
  def init_input_group(input_group={:param_hsh=>{}, :d_hsh=>{}, :context=>{}, :inputs=>[], :attrs=>{}})
    tags.each_with_object(input_group) {|(key, selected), hsh| Item.case_merge(input_group, (tag_attr?(key.split('::')[1]) ? selected : fieldables.detect{|f| f.id==(selected.to_i)}), :param_hsh, *key.split('::'))}
  end

  ##############################################################################
  ##############################################################################

  def artist_params(context, attrs, d_hsh, k='artist')
    return unless artist
    d_hsh.merge!({k=> artist.artist_params['d_hsh']})
    attrs.merge!(artist.artist_params['attrs'])
    field_context_order(k, d_hsh[k], context)
  end

  def title_params(context, attrs, d_hsh, k='title')
  	config_title_value(context, d_hsh, k)
  	attrs[k] = attrs_title
  end

  def config_title_value(context, d_hsh, k)
  	admin_tb_keys.each do |tag_key|
  		if v = public_send("#{tag_key}_#{k}")
  			Item.case_merge(d_hsh, v, k, tag_key)
        set_order(context, tag_key.to_sym, k)
  		end
  	end
  end

  ##############################################################################
  def config_conditional_kinds(input_group, context, d_hsh)
    extract_meth_hsh(conditional_kinds, d_hsh).each do |hsh|
      sub_hsh = hsh[:k]=='dimension' ? d_hsh.dig('mounting', 'mounting_search') : hsh[:k_hsh].slice!(*tb_keys)
      config_conditional_kind(hsh[:k], hsh[:klass], d_hsh, hsh[:k_hsh], sub_hsh, input_group, context)
    end
  end

  def config_conditional_kind(k, klass, d_hsh, kind_hsh, sub_hsh, input_group, context, meth_key='config')
  	if tb_hsh = handle_public_kind(k, klass, kind_hsh, sub_hsh, input_group, context, meth_key)
  		d_hsh[k] = tb_hsh
  		set_context(k, context)
  		field_context_order(k, tb_hsh, context)
  	end
  end

  def config_compound_kinds(input_group, context, d_hsh)
    extract_meth_hsh(compound_kinds, d_hsh).each do |hsh|
      d_hsh[hsh[:k]] = handle_public_kind(hsh[:k], hsh[:klass], hsh[:k_hsh], hsh[:k_hsh].slice!(*tb_keys), input_group, context, 'config')
    end
  end

  def extract_meth_hsh(meth_hsh, d_hsh)
    meth_hsh.transform_values {|kinds| kinds.select{|k| d_hsh[k]}.map{|k| {k: k, k_hsh: hsh_slice_and_delete(d_hsh, k)}}}.select{|klass, kinds| kinds.any?}.each {|klass, kinds| kinds.map{|hsh| hsh[:klass] = klass}}.values.flatten
  end

  def handle_public_kind(k, klass, kind_hsh, sub_hsh, input_group, context, meth_key)
  	to_class(klass).public_send("#{meth_key}_#{k}", k, kind_hsh, sub_hsh, input_group, context)
  end

  ##############################################################################
  # gartner_blade_params ####################################################### GartnerBlade
  def gartner_blade_params(keys, context, d_hsh, attrs, store)
    gb_hsh = slice_vals_and_delete(d_hsh, keys)
    unrelated_params(context, gb_hsh, store)
    title_hsh = slice_vals_and_delete(store, %w[size color sculpture_type lid])
    title = title_hsh.inject([]) {|a,(k,v_hsh)| a << v_hsh['tagline']}.join(' ')
    GartnerBlade.new.build_gartner_blade(keys, title, context, attrs, store)
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

  # utility methods ############################################################ #symbolize: move to textable, tb_keys: remove
  def symbolize(w)
    w.downcase.split(' ').join('_').to_sym
  end

  def tb_keys
    %w[tagline invoice_tagline search_tagline body]
  end

  def admin_tb_keys
    tb_keys.values_at(0,-1)
  end

  def all_title_keys
    tb_keys[0..2]
  end

  ##############################################################################

  def config_form_group(input_group, tags)
    input_group[:context][product_category(tags['product_type'])] = true
    input_group[:rows] = build_form_rows(input_group[:inputs].group_by{|h| h[:k]}, media_group(input_group[:context]).merge!(form_groups))
  end

  def related_form_rows(form_hsh)
  	form_hsh['dimension'].each do |f_hsh|
  		if Dimension.material_units.include?(f_hsh[:f_name]) || Dimension.mounting_units.exclude?(f_hsh[:f_name])
  			form_hsh[form_hsh['material'] ? 'material' : 'medium'].append(f_hsh)
  		else
  			form_hsh['mounting'].append(f_hsh)
  		end
  	end
  end

  def media_group(context)
    case
      when context[:flat_art]; {'media'=> {header: %w[category medium], body: %w[embellishing leafing remarque]}}
      when context[:sculpture_art]; {'media'=> {header: %w[category embellishing medium sculpture_type], body: %w[]}}
      when context[:gartner_blade]; {'media'=> {header: %w[sculpture_type sculpture_part], body: %w[]}}
    end
  end

  def form_groups
    {
      'material'=> {header: %w[material], body: %w[]},
      'mounting'=> {header: %w[mounting], body: %w[]},
      'numbering'=> {header: %w[numbering], body: %w[]},
      'authentication'=> {header: %w[seal signature certificate], body: %w[dated verification]},
      'disclaimer'=> {header: %w[disclaimer], body: %w[]},
      'dimension'=> {header: %w[dimension], body: %w[]}
    }
  end

  def build_form_rows(form_hsh, form_group)
    related_form_rows(form_hsh)
    form_group.each_with_object({}) do |(card_id,card), hsh|
      Item.case_merge(hsh, build_row(card[:header], form_hsh), card_id, :header)
      Item.case_merge(hsh, build_row(card[:body], form_hsh), card_id, :body)
    end
  end

  def build_row(keys,hsh)
    row = keys.select{|k| hsh.has_key?(k)}.each_with_object([]){|k,div_row| div_row << hsh[k]}.flatten
    row = row.each_with_index {|f_hsh,i| f_hsh[:i] = i}
    row
  end
end

# THE END ######################################################################
# def related_field_params(input_group, f, k)
# 	public_send("related_#{k}_params", input_group, f, k) if Dimension.related_kinds.include?(k) #Material.method_exists?("related_#{k}_params") #Dimension.related_kinds.include?(k) &&
# end
#
# def related_dimension_params(input_group, f, k, sub_key='material_dimension', tag_key='tag')
# 	if tag = f.tags[sub_key]
# 		Item.case_merge(input_group[:d_hsh], tag, 'dimension', sub_key, tag_key)
#     related_mounting_search(input_group, f, k) if k=='mounting'
# 	end
# end
#
# def related_mounting_params(input_group, f, k, sub_key='mounting_dimension', tag_key='tag')
#   related_dimension_params(input_group, f, k, sub_key, tag_key)
# end
#
# def related_material_params(input_group, f, k, k2='mounting')
# 	related_material_mounting(input_group, f, k2)
#   related_mounting_search(input_group, f, k2)
# end
#
# def related_material_mounting(input_group, f, k, sub_key='material_mounting', tag_key='body')
#   if material_mounting = f.tags[sub_key]
#     Item.case_merge(input_group[:d_hsh], material_mounting, k, tag_key)
#     set_order(input_group[:context], tag_key.to_sym, k)
#   end
# end
#
# def related_mounting_search(input_group, f, k, sub_key='mounting_search')
#   if mounting_search = f.tags[sub_key]
#     Item.case_merge(input_group[:d_hsh], f.tags[sub_key], k, sub_key)
#   end
# end

# def form_groups
#   {
#     'numbering'=> {header: %w[numbering], body: %w[]},
#     'material_mounting'=> {header: %w[mounting], body: %w[]},
#     'authentication'=> {header: %w[seal signature certificate], body: %w[dated verification]},
#     'dimension'=> {header: %w[dimension], body: %w[]},
#     'disclaimer'=> {header: %w[disclaimer], body: %w[]}
#   }
# end

# def finish_config_group(input_group, context, d_hsh)
#   set_compound_keys(context)
#   config_dependent_kinds(input_group, context, d_hsh)
# end
#
# def config_dependent_kinds(input_group, context, d_hsh)
#   dependent_kinds_hsh(context[:body][:order].keys).each do |klass, kinds|
#     kinds.map {|k| config_public_kind(k, klass, d_hsh[k], d_hsh[k].slice!(*tb_keys), input_group, context)}
#   end
# end
#
# def config_public_kind(k, klass, tb_hsh, k_hsh, input_group, context)
# 	to_class(klass).public_send("config_#{k}", k, tb_hsh, k_hsh, input_group, context)
# end

# def config_prev_kind(prevk, k, kset, input_group, context, d_hsh)
#   kset << k if prevk != k
#   if kset.count>1 && prevk != k
#     config_compound_kind(k, input_group, context, d_hsh)
#   end
# end

##############################################################################
# divergent_params
##############################################################################
# def divergent_params(context, d_hsh, attrs, store)
#   if context[:gartner_blade]
#     gartner_blade_params(contexts[:gartner_blade], context, d_hsh, attrs, store)
#   else
#     standard_params(context, d_hsh, attrs, store)
#   end
# end
