class Product < ApplicationRecord

  include Fieldable
  include FieldCrud
  include Crudable
  include Hashable
  include TypeCheck
  include Search
  include CSVSeed

  validates :product_name, presence: true
  validates :product_name, uniqueness: true

  has_many :item_groups, as: :origin
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, as: :origin, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  def config_form_group(f_grp)
    product_attrs(f_grp[:context], f_grp[:attrs], tags)
    f_grp[:rows] = build_form_rows(f_grp[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
    f_grp[:d_hsh] = f_grp[:tag_hsh]
    f_grp
  end

  def product_attrs(f_grp)
    f_grp[:context][product_category(tags['product_type'])] = true
    Medium.tag_keys.map{|k| f_grp[:attrs][k] = tags[k]}
  end

  def inputs_and_tag_hsh(input_group)
  	unpacked_fields.each_with_object(input_group) do |f, input_group|
  		k, t, f_name = pull_tags_and_return_fargs(f, input_group, *f.fattrs)
  		next if no_assocs?(t)
  		config_input_and_selected(k, t, f_name, f, input_group)
  	end
  end

  def unpacked_fields(fields:nil, set:[])
  	(fields ? fields : fieldables).each_with_object(set) do |f, set|
  		field_set?(f.type) ? unpacked_fields(fields: f.fieldables, set: set) : set.push(f)
  	end
  end

  ##############################################################################

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

  # COLLECTIONS ################################################################
  def items
    Item.joins(:products).where(products: {id: id})
  end

  def artists
    Artist.sorted_set(Artist.joins(:items).where(items: {id: items})).uniq
  end

  class << self

    def search(scopes:, product_hattrs:, context:)
      inputs = config_search_params(context, scopes, product_hattrs)
    	filter_results_and_config_hattr_inputs(product_hattrs, :product, inputs)
      reset_scopes(inputs[:product][:opts], scopes, inputs) if context=='hattrs'
      config_artist_inputs(scopes[:product], scopes[:artist], inputs[:product][:opts], scopes, inputs)
    	inputs
    end

    def config_search_params(context, scopes, product_hattrs)
      inputs = initialize_search_inputs(scopes)
    	inputs[:hattrs] = initialize_search_inputs(product_hattrs)
    	inputs[:product][:opts] = product_set(scopes[:product], scopes[:artist], context)
      inputs
    end

    def product_set(product, artist, context)
    	artist && product || artist && context != 'hattr' ? artist.products : sorted_products
    end

    def filter_results_and_config_hattr_inputs(hattrs, result_key, inputs, hstore='tags')
    	hattrs.each do |k,selected|
    		inputs[:hattrs][k][:opts] = search_opts(inputs[result_key][:opts].pluck(hstore),k)
    		filter_results_and_config_hattr_input(result_key, k, selected, hstore, inputs) if k=='category_search' || k=='material_search'
    		filter_results_and_config_medium_material_inputs(result_key, k, selected, hstore, inputs) if k=='medium_search'
    	end
    end

    def filter_results_and_config_hattr_input(result_key, hattr_key, selected, hstore, inputs)
    	if set = valid_scope_search(selected, search_query(inputs[result_key][:opts], {hattr_key=>selected}, hstore))
    		inputs[result_key][:opts] = set
    	elsif selected
    		inputs[:hattrs][hattr_key][:selected] = nil
    	end
    end

    def filter_results_and_config_medium_material_inputs(result_key, hattr_key, selected, hstore, inputs)
    	if filter_results_and_config_hattr_input(result_key, hattr_key, selected, hstore, inputs)
    		return
    	elsif inputs[:hattrs].keys[0]=='material_search'
    		filter_results_and_config_hattr_input(result_key, 'material_search', selected, hstore, inputs)
    	end
    end

    def config_artist_inputs(product, artist, products, scopes, inputs)
    	inputs[:artist][:opts] = product ? product.artists : Artist.with_these(products)
    	inputs[:title][:opts] = artist ? artist.titles : []
    end

    def reset_scopes(products, scopes, inputs)
    	reset_hattr(:product, scopes, inputs) if scopes[:product] && products.exclude?(scopes[:product])
    	[:artist, :title].map{|k| reset_hattr(k, scopes, inputs)} if scopes[:artist] && !scopes[:artist].has_any_of_these?(products)
    end

    def reset_hattr(k, scopes, inputs)
    	scopes[k] = nil
    	inputs[k][:selected] = nil
    end

    ############################################################################
    def grouped_fields
      Product.new.grouped_hsh(enum: sorted_fields.to_a, attrs: [:kind])
    end

    def sorted_fields
      FieldItem.where(id: ItemGroup.join_group('Product', Product.all.ids, %w[FieldSet SelectMenu RadioButton SelectField]).pluck(:target_id).uniq)
    end

    def field_tags(tags)
    	(Product.new.tb_keys+hattr_keys).select{|tag_key| tags[tag_key]}
    end

    ############################################################################

    def with_these(items)
    	Product.where(id: items.includes(:products).map(&:products).flatten.uniq)
    end

    # SEARCH METHODS ###########################################################
    def scope_keys
      %w[product_id artist_id title]
    end

    def hattr_keys
      %w[category_search medium_search material_search]
    end

    def search_keys
      %w[category_search medium_search]
    end

    def ordered_search_keys
      %w[category_search medium_search material_search]
    end

    # COLLECTIONS ##############################################################
    def sorted_products
      all.order(order_hstore_query(ordered_search_keys, 'tags'))
    end

    # SEEDING METHODS ##########################################################
    def seed(store)
      Medium.class_group('ProductGroup').each_with_object(store) do |c, store|
        c.product_group(store)
      end
    end

    def builder(product_name, fields, tags=nil)
      p = where(product_name: product_name).first_or_create
      p.update_tags(tags)
      p.config_assocs(fields)
      p.assoc_targets(fields)
      p.save
    end

    def csv_seed
      [FieldSet, SelectMenu, SelectField, Product].map{|c| c.build_field_assocs}
    end
  end

  def assoc_targets(targets)
    targets.each_with_object(self){|target,p| assoc_unless_included(target)}
  end

end


# def update_assocs(fields)
# 	self.assocs = assign_or_merge(target.assocs, {assoc=>true})
# 	self.save
# end

# def config_assocs(fields)
#   self.assocs = fields.each_with_object({}).each_with_index {|(f,h),i| h[[f.type,f.field_name,f.kind].join('::')] = i+1}
# end

# def config_form_group(f_grp)
# 	product_attrs(f_grp[:context], f_grp[:attrs], tags)
# 	#inputs_and_tags = inputs_and_tag_hsh(f_grp)
# 	f_grp[:rows] = build_form_rows(inputs_and_tags[:inputs].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
# 	f_grp[:d_hsh] = inputs_and_tags[:tag_hsh]
#   puts "d_hsh=> #{f_grp[:d_hsh]}"
# 	f_grp
# end

# def product_attrs(context, attrs, p_tags)
#   context[product_category(p_tags['product_type'])] = true
#   Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
# end

# GROUPING METHODS: CRUD/VIEW ################################################
# def product_item_loop(i_hsh, f_grp, keys)
#   product_attrs(f_grp[:context], f_grp[:attrs], tags)
#   product_item_fields_loop(g_hsh, i_hsh, f_grp[:rows], f_grp[:d_hsh], keys)
#   f_grp[:rows] = build_form_rows(f_grp[:rows].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
# end

# inputs_and_selected_make_attrs_and_rows ####################################
# def product_item_fields_loop(g_hsh, i_hsh, rows, d_hsh, keys)
#   inputs = product_fields_loop(g_hsh, d_hsh, keys)
#   item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
# end
#
# def product_fields_loop(g_hsh, d_hsh, keys, inputs=[])
#   Product.dig_keys_with_end_val(h: g_hsh).each_with_object(inputs) do |args, inputs|
#     k, t, t_type, f_name, f = input_vals(*args[0..-2].map!(&:underscore).append(args[-1]))
#     tags_loop(k, f_name, f, d_hsh, keys) if f.tags
#     if field_set?(t)
#       product_fields_loop(f.g_hsh, d_hsh, keys, inputs)
#     elsif !radio_button?(t)
#       inputs.append(input_hsh(k, t, f_name, f))
#     end
#   end
# end
#
# def item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
#   inputs.each do |f_hsh|
#     k, t, t_type, f_name, f = [:k,:t,:t_type,:f_name,:f_val].map{|key| f_hsh[key]}
#     selected = i_hsh.dig(k, t_type, f_name)
#     rows.append(f_hsh.merge!({:selected=> format_selected(selected,:id)}))
#     tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys) if selected
#   end
# end
#
# def tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys)
#   if selected.is_a?(String)
#     Item.case_merge(d_hsh, selected, k, f_name)
#   else
#     tags_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
#     product_item_fields_loop(selected.g_hsh, i_hsh, rows, d_hsh, keys) if field_set?(selected.type)
#   end
# end

# def tags_loop(k, f_name, f, d_hsh, keys)
#   keys.each_with_object(d_hsh) do |tag, d_hsh|
#     Item.case_merge(d_hsh, f.tags[tag], k, tag, f_name) if f.tags&.has_key?(tag)
#   end
# end

# def format_selected(selected, attr)
#   return selected if selected.nil? || selected.is_a?(String)
#   selected.public_send(attr)
# end

# def format_fname(k, selected, f_name)
#   k == 'dimension' && field_set?(selected.type) ? selected.field_name : f_name
# end

# def show_product_group(fields, i_hsh, options, field_sets, input_group={:inputs=>[], :tag_hsh=>{}})
# 	fields.each_with_object(input_group) do |f, input_group|
# 		k, t, f_name = pull_tags_and_return_fargs(f, input_group, *fattrs(f))
# 		next if no_assocs?(f.type)
# 		input_group[:inputs] << f_hsh(k, t, f_name, f)
# 		show_item_group(f_assoc(t), i_hsh.dig(tag_key(k, f_assoc(t), f_name)), options, field_sets, i_hsh, input_group)
# 	end
# end
#
# #t_type, i_hsh.dig(tag_key(k, f_assoc(t), f_name)), options, field_sets, i_hsh, input_group
# def show_item_group(t_type, selected_param, options, field_sets, i_hsh, input_group)
# 	return unless selected_param
# 	input_group[:inputs][-1][:selected] = selected_param
# 	return if tag_attr?(t_type)
# 	f = (option?(t_type) ? options : field_sets).detect{|f| f.id==selected_param}
# 	k, t, f_name = pull_tags_and_return_fargs(f, input_group, *fattrs(f))
# 	show_product_group(f.fieldables, i_hsh, options, field_sets, input_group) if field_set?(t)
# end

# def new_product_group(fields, input_group={:inputs=>[], :tag_hsh=>{}})
# 	fields.each_with_object(input_group) do |f, input_group|
# 		k, t, f_name = pull_tags_and_return_fargs(f, input_group, *fattrs(f))
# 		next if no_assocs?(f.type)
# 		input_group[:inputs] << f_hsh(k, t, f_name, f)
# 		new_item_group(default_field(k, t, f), input_group)
# 	end
# end
#
# def new_item_group(f_val, input_group)
# 	return unless f_val
# 	input_group[:inputs][-1][:selected] = f_val.id
# 	k, t, f_name = pull_tags_and_return_fargs(f_val, input_group, *fattrs(f_val))
# 	return if no_assocs?(t)
# 	input_group[:inputs] << f_hsh(k, t, f_name, f_val)
# 	new_product_group(f_val.fieldables, input_group) if field_set?(f_val.type)
# end

# THE END ######################################################################
# def product_search(set, search_params, hstore='tags')
#   search_query(set, search_params, hstore).order(order_hstore_query(ordered_search_keys, hstore))
# end
#
# def scoped_products(set, k, hattrs)
#   product_search(set, {k=> hattrs[k]})
# end
################################################################################
# def search_by_artists(artist_id)
#   where(id: ItemGroup.join_group('Item', Item.artist_items(artist_id).ids, 'Product').pluck(:target_id))
# end

# def titles
#   items.pluck(:title).uniq.reject{|i| i.blank?}
# end

############################################################################

# def kinds
#   Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
# end

# DRAFT/REPLACED METHODS #######################################################
#a = lambda {puts "dog"}#{Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)}
# def my_lambda
#   lambda {puts "dog"}
#   #a.call
# end

################################################################################ f.tags&.has_key?(tag)
# def radio_options
#   radio_buttons.includes(:options).map(&:options)
# end

# targets.includes(item_groups: :target).map(&:target)
# FieldItem.where(id: targets.map(&:id)).joins(:item_groups).order('item_groups.sort').includes(:target).map(&:target)

# REFACTORED SEARCH METHODS ####################################################

# def search(scopes:, product_hattrs:)
# 	hattrs, products, product_opts, inputs = config_scopes(product_hattrs, product_hattrs.reject{|k,v| v.blank?}, scopes)
#   config_hattrs_and_their_inputs(product_hattrs, hattrs, product_opts, inputs)
#   config_scopes_and_their_inputs(scopes[:product], scopes[:artist], products, hattrs.reject{|k,v| v.blank?}, inputs)
# 	#config_params_and_their_inputs(product_hattrs, scopes[:product], scopes[:artist], hattrs, products, product_opts, inputs)
# 	inputs
# end

# def config_scopes(product_hattrs, search_params, scopes)
# 	products = config_selected_scopes_and_initialize_products(scopes[:product], scopes[:artist], scopes, search_params)
# 	[product_hattrs, products, products, initialize_scope_inputs(scopes).merge!({:hattrs=>[]})]
# end


# def config_titles(artist)
# 	artist ? artist.titles : []
# end
#A #########################################################################

# def initialize_scope_inputs(scopes)
# 	scopes.each_with_object({}) do |(k,v), inputs|
# 		v = nil if v.blank?
# 		inputs[k.to_s] = {:selected => (v.present? && v.class != String ? v.id : v), :opts => []}
# 	end
# end
#C: sorted_products OR artist.products =>
# def config_selected_scopes_and_initialize_products(product, artist, scopes, search_params)
# 	if product && !artist || !product && !artist
# 		config_scopes_for_products(artist, scopes, sorted_products)
# 	else
# 		config_scopes_for_artist_products(scopes, artist.products, search_params)
# 	end
# end
#
# #C.1: reset artist & title if needed
# def config_scopes_for_products(artist, scopes, products)
# 	reset_artist(scopes) if artist && Artist.with_these(products).exclude?(artist)
# 	products
# end
#
# #C.2: reset artist & title if needed; return either: product_search(products, search_params) OR sorted_products
# def config_scopes_for_artist_products(scopes, products, search_params)
# 	return products if search_params.none? || product_search(products, search_params).any?
#   reset_artist(scopes)
# 	sorted_products
# end
#
# #C.1.a
# def reset_artist(scopes)
#   scopes[:artist] = nil
#   scopes[:title] = nil if scopes.dig(:title)
# end

# def config_hattrs_and_their_inputs(product_hattrs, hattrs, products, inputs)
#   product_hattrs.each do |k,selected|
#     products = category_search(k, selected, products, hattrs, inputs[:hattrs]) if k=='category_search'
#     products = medium_search(k, selected, products, hattrs, inputs[:hattrs]) if k=='medium_search'
#     material_search(k, selected, products, hattrs, inputs[:hattrs]) if k=='material_search'
#   end
# end

#
# def config_scopes_inputs(product, artist, products, search_params, scope_inputs)
# 	scope_inputs[:product][:opts] = products
# 	scope_inputs[:artist][:opts] = config_artists(product, products)
# 	scope_inputs[:title][:opts] = config_titles(artist)
# end
#
# def config_artists(product, products)
# 	product ? product.artists : Artist.with_these(products)
# end

# def config_input_and_products(k, selected, products, hattr_inputs)
#   config_input(k, selected, products, hattr_inputs)
# 	products
# end

# def config_input_and_scope_products(k, selected, products, hattr_inputs, scoped_products)
#   config_input(k, selected, products, hattr_inputs)
# 	scoped_products
# end

# def config_input(k, selected, products, hattr_inputs)
# 	hattr_inputs.append(search_input(k, selected, products.pluck(:tags)))
# end

# def config_scopes_and_their_inputs(product, artist, products, search_params, inputs)
# 	inputs[:product][:opts] = config_products(product, artist, products, search_params)
# 	inputs[:artist][:opts] = config_artists(product, inputs[:product][:opts])
# 	config_titles(artist, inputs) if inputs[:title]
# end

# def config_products(product, artist, products, search_params)
#   products = search_params.any? ? product_search(products, search_params) : products
#   products
# end

# BEGIN KILL
# def category_search(k, selected, products, hattrs, hattr_inputs)
#   config_input(k, selected, products, hattr_inputs)
#   selected ? scoped_products(products, k, hattrs) : products
# end

# def medium_search(k, selected, products, hattrs, hattr_inputs)
#   if scoped_products = results_or_reset_hattr(k, selected, products, hattrs)
#     config_input_and_scope_products(k, selected, products, hattr_inputs, scoped_products)
#   elsif material_products = material_scope(hattrs, products)
#     config_input_and_products(k, selected, material_products, hattr_inputs)
#   else
#     config_input_and_products(k, selected, products, hattr_inputs)
#   end
# end
#
# def material_search(k, selected, products, hattrs, hattr_inputs)
# 	reset_hattr_param(k, selected, products, hattrs)
#   config_input(k, hattrs[k], products, hattr_inputs)
# end

# def results_or_reset_hattr(k, selected, products, hattrs)
#   if scoped_products = valid_scope_search(selected, scoped_products(products, k, hattrs))
#     scoped_products
#   elsif selected
#     hattrs[k] = nil
#   end
# end



# def material_scope(hattrs, products)
#   valid_set(scoped_products(products, 'material_search', hattrs)) if material_scope?(hattrs)
# end

# def material_scope?(hattrs)
#   hattrs && !hattrs.dig('material_search').blank? && hattrs['medium_search'].blank? && hattrs['category_search'].blank?
# end
