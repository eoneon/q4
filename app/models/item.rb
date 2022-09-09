class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ProductCrud
  include ItemProduct
  include KindContext
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

  # def merge_tag_hsh(i_params)
  #   i_params.each_with_object({}) do |(k,v), tag_hsh|
  #   	k,t,f_name = k.split('::')
  #   	Item.case_merge(tag_hsh, v, k, t, f_name) if tag_attr?(t)
  #   end
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

# def update_prev_kind(k, input_group)
#   if !input_group[:prev_kind]
#     input_group[:prev_kind] = k
#   elsif input_group[:prev_kind] != k
#     #puts "2-k=>#{k}, 2-prev_kind=>#{input_group[:prev_kind]}"
#     update_prev_kind_case(input_group[:prev_kind], tb_keys, input_group[:context], input_group[:d_hsh])
#   	input_group[:prev_kind] = k
#     #puts "d_hsh=>#{input_group[:d_hsh]}"
#   end
# end

# def update_prev_kind_case(k, tb_keys, context, d_hsh)
#   puts "d_hsh[k]=>#{d_hsh[k]}"
# 	case k
# 	when 'numbering'; LimitedEdition.config_numbering_params(k, tb_keys, context, d_hsh)
# 	end
# end

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
