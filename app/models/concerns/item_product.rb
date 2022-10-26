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
  	finish_config_group(input_group, input_group[:context], input_group[:d_hsh])
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
    config_dimensions(input_group, input_group[:context], input_group[:d_hsh])
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
      k = reset_kind(k, f_name)
      context_from_selected(k, t, f_name, selected, input_group[:context])
      tag_attr?(t) ? selected_tag_attr(input_group[:d_hsh], selected, k, f_name) : selected_field(input_group, selected, k, selected.type.underscore, selected.field_name.underscore)
  	end
  end

  def reset_kind(k, f_name)
    k=='seal' ? f_name : k
  end

  def selected_tag_attr(d_hsh, selected, k, f_name)
    if k=='dimension'
      Dimension.measurement_hsh(d_hsh, selected, k, f_name)
    else
      Item.case_merge(d_hsh, selected, k, f_name)
    end
  end

  def selected_field(input_group, selected, k, t, f_name)
  	tags_from_selected_field(input_group[:d_hsh], input_group[:context], selected, k, t, f_name) if selected.tags
  	config_loop(fields: selected.fieldables, input_group: input_group) if field_set?(t)
  end

  def tags_from_selected_field(d_hsh, context, selected, k, t, f_name)
    related_field_params(d_hsh, selected, k, t, f_name) if Dimension.related_kinds.include?(k)
    tb_tags_from_field(d_hsh, selected, k) unless k=='dimension'
  end

  def tb_tags_from_field(d_hsh, f, k)
    (%w[material_mounting mounting_search] + tb_keys).map {|tag_key| Item.case_merge(d_hsh, f.tags[tag_key], k, tag_key)} if f.tags
  end

  def related_field_params(d_hsh, f, k, t, f_name)
    f.tags.select{|k,v| Dimension.tags.include?(k) && v != 'n/a'}.each do |tag_key, tag_val|
      Item.case_merge(d_hsh, tag_val, 'dimension', tag_key, 'tag')
    end
  end

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

  def config_dimensions(input_group, context, d_hsh, k='dimension')
  	if dimension_hsh = hsh_slice_and_delete(d_hsh, k)
      Dimension.config_dimension(k, dimension_hsh, input_group, context, d_hsh)
      field_context_order(k, d_hsh[k], context)
  	end
  end

  ##############################################################################

  def finish_config_group(input_group, context, d_hsh)
    set_compound_keys(context)
    config_dependent_kinds(input_group, context, d_hsh)
  end

  def config_dependent_kinds(input_group, context, d_hsh)
    dependent_kinds_hsh(context[:body][:order].keys).each do |klass, kinds|
      kinds.map {|k| config_public_kind(k, klass, d_hsh[k], d_hsh[k].slice!(*tb_keys), input_group, context)}
    end
  end

  def config_public_kind(k, klass, tb_hsh, k_hsh, input_group, context)
  	to_class(klass).public_send("config_#{k}", k, tb_hsh, k_hsh, input_group, context)
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
