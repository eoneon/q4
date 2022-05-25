class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ProductCrud
  include ItemProduct
  include BatchCreate
  include Hashable
  include TypeCheck
  include Description
  include Textable
  include ExportAttrs
  include SkuRange
  include Search

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :products, through: :item_groups, source: :target, source_type: "Product"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  belongs_to :invoice, optional: true

  before_create :set_qty

  def set_qty
    self.qty = 1 if qty.blank?
  end

  # COLLECTIONS ################################################################
  def product
    products.first if products.any?
  end

  def artist
    artists.first if artists.any?
  end

  def hattr(hstore,k)
    public_send(hstore).dig(k) unless !public_send(hstore)
  end

  def i_args
    {i_params: config_item_params, options: options, field_sets: joined_field_sets} if tags
  end
  ##############################################################################

  def sku_pos
    invoice.skus.index(self)
  end

  def first_sku
    invoice.first_sku
  end

  def last_sku
    invoice.last_sku
  end

  def next_sku
    invoice.skus[sku_pos+1]
  end

  def prev_sku
    invoice.skus[sku_pos-1]
  end

  ##############################################################################

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
  def unpacked_fields
  	fieldables.each_with_object([]) do |f, set|
  		set.push(f)
  		set.push(*f.fieldables) if field_set?(f.type)
  	end
  end

  def joined_field_sets
  	field_sets.each_with_object([]) do|f,set|
  		set.push(f)
  		set.push(*f.field_sets) if f.field_sets.any?
  	end
  end

  # def param_group
  # 	return nil if !tags
  # 	input_group = {:options=> options, :field_sets=> field_sets, :inputs=> []}
  # 	input_group[:tag_hsh] = input_group.values.each_with_object({}) {|fields,h| fields.map{|f| tag_key_loop(*f.fattrs, f, h)}}
  # 	input_group[:i_params] = config_item_params
  # 	input_group
  # end

  def param_group(input_group={:inputs=> []})
    input_group[:tag_hsh] = options.each_with_object({}) {|opt,tag_hsh| tag_key_loop(*opt.fattrs, opt, tag_hsh)}
    input_group[:i_params] = config_item_params
    input_group
  end

  def inputs_and_tag_hsh(fields:nil, input_group:nil)
    (fields ? fields : field_sets).each_with_object(input_group ? input_group : param_group) do |f, input_group|
      k, t, f_name = pull_tags_and_return_fargs(f, input_group, *f.fattrs)
      if field_set?(f.type)
        inputs_and_tag_hsh(fields: f.fieldables, input_group: input_group)
      else
        config_input_and_selected(k, t, f_name, f, input_group)
      end
    end
  end

  # def inputs_and_tag_hsh(fields:nil, input_group:)
  # 	(fields ? fields : input_group[:field_sets]).each_with_object(input_group) do |f, input_group|
  # 		if no_assocs?(f.type)
  # 			tag_key_loop(*f.fattrs, f, input_group[:tag_hsh])
  # 		elsif field_set?(f.type)
  # 			inputs_and_tag_hsh(fields: f.fieldables, input_group: input_group)
  # 		else
  # 			k, t, f_name = pull_tags_and_return_fargs(f, input_group, *f.fattrs)
  # 			input_group[:inputs] << f_hsh(k, t, f_name, f)
  # 			set_selected_and_push(input_group, input_group[:i_params].dig(tag_key(k, t_type(t), f_name)))
  # 		end
  # 	end
  # end

  ##############################################################################

  class << self

    def search(scopes:, product_hattrs:, item_hattrs:, context: nil)
    	inputs = Product.search(scopes: scopes, product_hattrs: product_hattrs, context: context)
      results_and_inputs(scopes[:product], scopes[:artist], scopes[:title], inputs[:product][:opts], valid_params(item_hattrs), item_hattrs, inputs)
    	inputs
    end

    def results_and_inputs(product, artist, title, products, item_params, item_hattrs, inputs, hstore='csv_tags')
      items = item_results(product, artist, title, valid_hattr_params(inputs[:hattrs]).merge(item_params), hstore)
      inputs[:items] = uniq_and_sorted_set(items, hstore, table_keys)
      inputs[:hattrs].merge!(initialize_search_inputs(item_hattrs, inputs[:items].pluck(hstore)))
    end

    def item_results(product, artist, title, search_params, hstore)
    	items = item_set(product, artist)
    	items = search_query(items, search_params, hstore)
    	items.any? && title ? items.where(title: title) : items
    end

    def item_set(product, artist)
    	case
    		when !product && !artist; []
    		when product && artist; artist.product_items(product)
    		when product; product.items
    		when artist; artist.items
    	end
    end

    def table_keys
    	%w[search_tagline mounting_search item_size width height]
    end

    def scope_keys
      %w[product_id artist_id title]
    end

    def hattr_keys
      %w[mounting_search measurements edition]
    end

    def search_keys
      %w[category_search medium_search material_search mounting_search measurements edition] #measurements item_size
    end

    def items_scoped_by_products(products)
      joins(:products).where(products: {id: products.ids})
    end

    def with_these(products)
    	joins(:products).where(products: {id: products}).uniq
    end

    def artist_items(artist_id)
      joins(:artists).where(artists: {id: artist_id}).distinct
    end
  end

end

############################################################################## #results_or_self = attr_group(results_or_self, default_params(attrs, attr_search_keys), input_group)
############################################################################
# def item_search_hattr_inputs(hattrs, items_tags)
#   hattrs.each_with_object([]) do |(k,v), hattr_inputs|
#     #{k=>search_input(k,v,items_tags)}
#     hattr_inputs.append({'input_name'=> k, 'selected'=> v, 'opts'=> search_opts(items_tags, k)})
#   end
# end

# def item_search(product:nil, artist:nil, title: nil, hattrs:nil, hstore:'csv_tags', inputs:{})
#   hattrs = hattr_params(product, hattrs, hstore)
#   results_or_self = search_case(artist, product)
#   results_or_self = title_search(results_or_self, title)
#   results = hstore_cascade_search(results_or_self, hattrs.reject{|k,v| v.blank?}, hstore, [])
#   results = order_hstore_search(results, %w[search_tagline item_size], hstore)
#   a, b = uniq_hattrs(results, search_keys, hstore), form_inputs(product, artist, title, hattrs, results, hstore, inputs)
# end
#
# def form_inputs(product, artist, title, hattrs, results, hstore, inputs)
#   origins_targets_inputs(product, 'Item', 'Product', results, inputs)
#   origins_targets_inputs(artist, 'Item', 'Artist', results, inputs)
#   inputs['title'] = {'selected' => title, 'opts'=> (results.any? ? results.pluck(:title).uniq : results)}
#   results, hstore = results.any? ? [results, hstore] : [Product, 'tags']
#   inputs['hattrs'] = search_inputs(results, hattrs, hstore)
#   inputs
# end
#
# def search_case(artist, product)
#   case
#     when artist && product; artist.product_items(product)
#     when artist; artist.items
#     when product; product.items
#     when !artist && !product; self
#   end
# end
#
# def title_search(results_or_self, title)
#   title.blank? ? results_or_self : results_or_self.where(title: title)
# end

# def self.hattr_search_fields(results, hattrs, hstore)
#   hattrs.each_with_object({}) do |(k,v), hattr_inputs|
#     hattr_inputs.merge!({k=> search_input(k, v, results, hstore)})
#   end
# end
#
# def self.hattr_opts(results, k, hstore)
#   results.map{|i| i.public_send(hstore)[k]}.uniq.compact
# end
#
# def self.attr_search_fields(attrs, results)
#   attrs.each_with_object({}) do |(k,v), attr_inputs|
#     attr_inputs.merge!({k => {'opts' => results.pluck(k.to_sym).uniq, 'selected' =>v}})
#   end
# end
