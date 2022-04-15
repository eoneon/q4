class Product < ApplicationRecord

  include Fieldable
  include Crudable
  include Hashable
  include TypeCheck
  include Search

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

  # GROUPING METHODS: CRUD/VIEW ################################################
  def product_item_loop(i_hsh, f_grp, keys)
    product_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], tags)
    product_item_fields_loop(g_hsh, i_hsh, f_grp[:rows], f_grp[:d_hsh], keys)
    f_grp[:rows] = build_form_rows(f_grp[:rows].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
  end

  def product_attrs(context, d_hsh, attrs, p_tags)
    context[product_category(p_tags['product_type'])] = true
    Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
  end

  # inputs_and_selected_make_attrs_and_rows ####################################
  def product_item_fields_loop(g_hsh, i_hsh, rows, d_hsh, keys)
    inputs = product_fields_loop(g_hsh, d_hsh, keys)
    item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
  end

  def product_fields_loop(g_hsh, d_hsh, keys, inputs=[])
    Product.dig_keys_with_end_val(h: g_hsh).each_with_object(inputs) do |args, inputs|
      k, t, t_type, f_name, f = input_vals(*args[0..-2].map!(&:underscore).append(args[-1]))
      tags_loop(k, f_name, f, d_hsh, keys) if f.tags
      if field_set?(t)
        product_fields_loop(f.g_hsh, d_hsh, keys, inputs)
      elsif !radio_button?(t)
        inputs.append(input_hsh(k, t, f_name, f))
      end
    end
  end

  def item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
    inputs.each do |f_hsh|
      k, t, t_type, f_name, f = [:k,:t,:t_type,:f_name,:f_val].map{|key| f_hsh[key]}
      selected = i_hsh.dig(k, t_type, f_name)
      rows.append(f_hsh.merge!({:selected=> format_selected(selected,:id)}))
      tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys) if selected
    end
  end

  def tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys)
    if selected.is_a?(String)
      Item.case_merge(d_hsh, selected, k, f_name)
    else
      tags_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
      product_item_fields_loop(selected.g_hsh, i_hsh, rows, d_hsh, keys) if field_set?(selected.type)
    end
  end

  def tags_loop(k, f_name, f, d_hsh, keys)
    keys.each_with_object(d_hsh) do |tag, d_hsh|
      Item.case_merge(d_hsh, f.tags[tag], k, tag, f_name) if f.tags&.has_key?(tag)
    end
  end

  def format_selected(selected, attr)
    return selected if selected.nil? || selected.is_a?(String)
    selected.public_send(attr)
  end

  def format_fname(k, selected, f_name)
    k == 'dimension' && field_set?(selected.type) ? selected.field_name : f_name
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

  # COLLECTIONS ################################################################
  def items
    Item.joins(:products).where(products: {id: id})
  end

  def artists
    Artist.sorted_set(Artist.joins(:items).where(items: {id: items})).uniq
  end

  class << self
    #A #########################################################################
    def search(scopes:, product_hattrs:)
    	hattrs, products, product_opts, inputs = config_scopes(product_hattrs, product_hattrs.reject{|k,v| v.blank?}, scopes)
    	config_params_and_their_inputs(product_hattrs, scopes[:product], scopes[:artist], hattrs, products, product_opts, inputs)
    	inputs
    end

    def config_scopes(product_hattrs, search_params, scopes)
    	products = config_selected_scopes_and_initialize_products(scopes[:product], scopes[:artist], scopes, search_params)
    	[product_hattrs, products, products, initialize_scope_inputs(scopes).merge!({'hattrs'=>[]})]
    end

    def config_params_and_their_inputs(product_hattrs, product, artist, hattrs, products, product_opts, inputs)
    	config_hattrs_and_their_inputs(product_hattrs, hattrs, product_opts, inputs)
    	config_scopes_and_their_inputs(product, artist, products, hattrs.reject{|k,v| v.blank?}, inputs)
    end

    def initialize_scope_inputs(scopes)
    	scopes.each_with_object({}) do |(k,v), inputs|
    		v = nil if v.blank?
    		inputs[k.to_s] = {'selected' => (v.present? && v.class != String ? v.id : v), 'opts' => []} #.merge!({'hattrs'=>[]})
    	end
    end
    #C: sorted_products OR artist.products =>
    def config_selected_scopes_and_initialize_products(product, artist, scopes, search_params)
    	if product && !artist || !product && !artist
    		config_scopes_for_products(artist, scopes, sorted_products)
    	else
    		config_scopes_for_artist_products(scopes, artist.products, search_params)
    	end
    end

    #C.1: reset artist & title if needed
    def config_scopes_for_products(artist, scopes, products)
    	reset_artist(scopes) if artist && Artist.with_these(products).exclude?(artist)
    	products
    end

    #C.2: reset artist & title if needed; return either: product_search(products, search_params) OR sorted_products
    def config_scopes_for_artist_products(scopes, products, search_params)
    	return products if search_params.none? || product_search(products, search_params).any?
      reset_artist(scopes)
    	sorted_products
    end

    #C.1.a
    def reset_title(scopes)
      scopes[:artist] = nil
      scopes[:title] = nil if scopes.dig(:title)
    end

    def config_hattrs_and_their_inputs(product_hattrs, hattrs, products, inputs)
      product_hattrs.each do |k,selected|
        products = category_search(k, selected, products, hattrs, inputs['hattrs']) if k=='category_search'
        products = medium_search(k, selected, products, hattrs, inputs['hattrs']) if k=='medium_search'
        material_search(k, selected, products, hattrs, inputs['hattrs']) if k=='material_search'
      end
    end

    def category_search(k, selected, products, hattrs, hattr_inputs)
      config_input(k, selected, products, hattr_inputs)
      selected ? scoped_products(products, k, hattrs) : products
    end

    def medium_search(k, selected, products, hattrs, hattr_inputs)
      if scoped_products = results_or_reset_hattr(k, selected, products, hattrs)
        config_input_and_scope_products(k, selected, products, hattr_inputs, scoped_products)
      elsif material_products = material_scope(hattrs, products)
        config_input_and_products(k, selected, material_products, hattr_inputs)
      else
        config_input_and_products(k, selected, products, hattr_inputs)
      end
    end

    def material_search(k, selected, products, hattrs, hattr_inputs)
    	reset_hattr_param(k, selected, products, hattrs)
      config_input(k, hattrs[k], products, hattr_inputs)
    end

    def results_or_reset_hattr(k, selected, products, hattrs)
      if scoped_products = valid_scope_search(selected, scoped_products(products, k, hattrs))
        scoped_products
      elsif selected
        hattrs[k] = nil
      end
    end

    def reset_hattr_param(k, selected, products, hattrs)
      hattrs[k] = nil if selected && scoped_products(products, k, hattrs).none?
    end

    def material_scope(hattrs, products)
      valid_set(scoped_products(products, 'material_search', hattrs)) if material_scope?(hattrs)
    end

    def material_scope?(hattrs)
      hattrs && !hattrs.dig('material_search').blank? && hattrs['medium_search'].blank? && hattrs['category_search'].blank?
    end

    def valid_scope_search(selected, set)
    	valid_set(set) if !selected.blank?
    end

    def valid_set(set)
    	set if set.any?
    end

    def config_input_and_products(k, selected, products, hattr_inputs)
      config_input(k, selected, products, hattr_inputs)
    	products
    end

    def config_input_and_scope_products(k, selected, products, hattr_inputs, scoped_products)
      config_input(k, selected, products, hattr_inputs)
    	scoped_products
    end

    def config_input(k, selected, products, hattr_inputs)
    	hattr_inputs.append(search_input(k, selected, products.pluck(:tags)))
    end

    def config_scopes_and_their_inputs(product, artist, products, search_params, inputs)
    	inputs['product']['opts'] = config_products(product, artist, products, search_params)
    	inputs['artist']['opts'] = config_artists(product, inputs['product']['opts'])
    	config_titles(artist, inputs) if inputs['title']
    end

    def config_products(product, artist, products, search_params)
      products = search_params.any? ? product_search(products, search_params) : products
      products
    end

    def config_artists(product, products)
    	product ? product.artists : Artist.with_these(products)
    end

    def config_titles(artist, inputs)
    	inputs['title']['opts'] = artist ? artist.titles : []
    end

    def product_search(set, search_params, hstore='tags')
      search_query(set, search_params, hstore).order(order_hstore_query(ordered_search_keys, hstore))
    end

    def scoped_products(set, k, hattrs)
      product_search(set, {k=> hattrs[k]})
    end

    # SEARCH METHODS ###########################################################
    def scope_keys
      %w[product_id artist_id title]
    end

    def hattr_keys
      %w[category_search medium_search material_search]
    end
    #end

    def search_keys
      %w[category_search medium_search] #material_search
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
      p.assoc_targets(fields)
    end

  end

  def assoc_targets(targets)
    targets.each_with_object(self){|target,p| assoc_unless_included(target)}
  end

end

# THE END ######################################################################
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
