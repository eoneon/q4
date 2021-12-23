class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ItemProduct
  include Hashable
  include TypeCheck
  include Description
  include Textable
  include ExportAttrs
  include SkuRange
  include Search

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :products, through: :item_groups, source: :target, source_type: "Product"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  ##############################################################################
  def self.item_search(product:nil, artist:nil, title: nil, hattrs:nil, hstore:'csv_tags', inputs:{})
    hattrs = hattr_params(product, hattrs, hstore)
    results_or_self = search_case(artist, product)
    results_or_self = title_search(results_or_self, title)
    results = hstore_cascade_search(results_or_self, hattrs.reject{|k,v| v.blank?}, hstore, [])
    results = order_hstore_search(results, %w[search_tagline item_size], hstore)
    a, b = uniq_hattrs(results, search_keys, hstore), form_inputs(product, artist, title, hattrs, results, hstore, inputs)
  end

  def self.form_inputs(product, artist, title, hattrs, results, hstore, inputs)
    origins_targets_inputs(product, 'Item', 'Product', results, inputs)
    origins_targets_inputs(artist, 'Item', 'Artist', results, inputs)
    inputs['title'] = {'selected' => title, 'opts'=> (results.any? ? results.pluck(:title).uniq : results)}
    results, hstore = results.any? ? [results, hstore] : [Product, 'tags']
    inputs['hattrs'] = search_inputs(results, hattrs, hstore)
    inputs
  end

  def self.search_case(artist, product)
    case
      when artist && product; artist.product_items(product)
      when artist; artist.items
      when product; product.items
      when !artist && !product; self
    end
  end

  def self.title_search(results_or_self, title)
    title.blank? ? results_or_self : results_or_self.where(title: title)
  end
  ##############################################################################

  def batch_create_skus(skus, sku_params, artist, product, product_args)
    skus.each do |sku|
      sku_params[:sku] = sku
      i = Item.create(sku_params)
      i.add_obj(artist) if artist
      i.add_sku(product, product_args, sku) if product
    end
  end

  def add_sku(product, product_args, sku)
    add_obj(product)
    self.tags = hsh_init(self.tags)
    add_default_fields(product_args)
    rows, attrs = input_group
    update_csv_tags(attrs)
  end

  ##############################################################################
  def update_product_case(t, old_val, new_val)
    old_id, new_id = item_val(t, old_val), param_val(t, new_val)
    case update_case(old_id, new_id)
      when :add; add_product(new_val(t, new_id))
      when :remove; remove_product(old_val)
      when :replace; replace_product(new_val(t, new_id), old_val)
    end
  end

  def add_product(product)
    add_obj(product)
    self.tags = hsh_init(self.tags)
    add_default_fields(product.f_args(product.g_hsh))
  end

  def remove_product(product)
    remove_fieldables
    remove_obj(product)
  end

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end

  def hsh_init(tags)
    tags ? tags : {}
  end

  ############################################################################## #results_or_self = attr_group(results_or_self, default_params(attrs, attr_search_keys), input_group)

  def self.search(scope:nil, attrs:{}, hattrs:{}, input_group:{}, hstore: 'csv_tags')
    results_or_self = scope_group(scope, :item_groups, input_group)
    results = hstore_group(results_or_self, default_params(hattrs, search_keys), hstore, input_group, nil)
    args = results.any? ? [results, input_group['hattrs'], hstore] : [Product, input_group['hattrs'], 'tags']
    input_group['hattrs'] = search_inputs(*args)
    a, b = results, input_group
  end

  def self.hattr_search_fields(results, hattrs, hstore)
    hattrs.each_with_object({}) do |(k,v), hattr_inputs|
      hattr_inputs.merge!({k=> search_input(k, v, results, hstore)})
    end
  end

  def self.hattr_opts(results, k, hstore)
    results.map{|i| i.public_send(hstore)[k]}.uniq.compact
  end

  def self.attr_search_fields(attrs, results)
    attrs.each_with_object({}) do |(k,v), attr_inputs|
      attr_inputs.merge!({k => {'opts' => results.pluck(k.to_sym).uniq, 'selected' =>v}})
    end
  end

  def self.table_keys
    %w[tagline_search mounting_search measurements]
  end

  def self.search_keys
    %w[category_search medium_search material_search mounting_search measurements] #measurements item_size
  end

  def self.artist_items(artist_id)
    joins(:artists).where(artists: {id: artist_id}).distinct
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

  def product
    products.first if products.any?
  end

  def artist
    artists.first if artists.any?
  end

  def hattr(hstore,k)
    public_send(hstore).dig(k) unless !public_send(hstore)
  end

end
