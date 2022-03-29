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

  ##############################################################################

  class << self

    def search(scopes:, product_hattrs:, item_hattrs:)
      inputs = Product.psearch(scopes: scopes, product_hattrs: product_hattrs)
      results_and_inputs(item_hattrs.reject{|k,v| v.blank?}, item_hattrs, scopes[:product], inputs)
      inputs
    end

    def results_and_inputs(search_params, item_hattrs, product, inputs, hstore='csv_tags')
      inputs['items'] = order_hstore_search(item_results(search_params, product, hstore), search_keys, hstore)
      items_tags = inputs['items'].any? ? inputs['items'].pluck(hstore) : []
      inputs['hattrs'].concat(item_search_hattr_inputs(item_hattrs, items_tags))
    end

    def item_results(search_params, product, hstore)
      product ? search_query(product.items, search_params, hstore) : []
    end

    def item_search_hattr_inputs(hattrs, items_tags)
      hattrs.each_with_object([]) do |(k,v), hattr_inputs|
        hattr_inputs.append({'input_name'=> k, 'selected'=> v, 'opts'=> search_opts(items_tags, k)})
      end
    end
    ############################################################################

    def item_search(product:nil, artist:nil, title: nil, hattrs:nil, hstore:'csv_tags', inputs:{})
      hattrs = hattr_params(product, hattrs, hstore)
      results_or_self = search_case(artist, product)
      results_or_self = title_search(results_or_self, title)
      results = hstore_cascade_search(results_or_self, hattrs.reject{|k,v| v.blank?}, hstore, [])
      results = order_hstore_search(results, %w[search_tagline item_size], hstore)
      a, b = uniq_hattrs(results, search_keys, hstore), form_inputs(product, artist, title, hattrs, results, hstore, inputs)
    end

    def form_inputs(product, artist, title, hattrs, results, hstore, inputs)
      origins_targets_inputs(product, 'Item', 'Product', results, inputs)
      origins_targets_inputs(artist, 'Item', 'Artist', results, inputs)
      inputs['title'] = {'selected' => title, 'opts'=> (results.any? ? results.pluck(:title).uniq : results)}
      results, hstore = results.any? ? [results, hstore] : [Product, 'tags']
      inputs['hattrs'] = search_inputs(results, hattrs, hstore)
      inputs
    end

    def search_case(artist, product)
      case
        when artist && product; artist.product_items(product)
        when artist; artist.items
        when product; product.items
        when !artist && !product; self
      end
    end

    def title_search(results_or_self, title)
      title.blank? ? results_or_self : results_or_self.where(title: title)
    end

    #new
    def scope_keys
      %w[product_id artist_id title]
    end

    def hattr_keys
      %w[mounting_search measurements edition]
    end
    #end

    def search_keys
      %w[category_search medium_search material_search mounting_search measurements edition] #measurements item_size
    end

    def items_scoped_by_products(products)
      joins(:products).where(products: {id: products.ids})
    end
    #
    # def items_scoped_by_artist(artist)
    #   joins(:artists).where(artists: {id: artist.id}).distinct
    # end

    def scoped_products(products)
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
