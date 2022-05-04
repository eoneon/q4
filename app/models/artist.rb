class Artist < ApplicationRecord
  include Search

  has_many :item_groups, as: :target
  has_many :items, through: :item_groups, source: :origin, source_type: "Item"

  def formal_name
    [artist_name, life_span].compact.join(' ')
  end

  def tagline
    title_tag ? "#{formal_name} #{title_tag}" : formal_name
  end

  def life_span(tag_keys=%w[yob yod])
    "(#{tag_keys.map{|k| tags[k]}.join('-')})" if tags &&  tag_keys.all?{|k| !tags.dig(k).blank?}
  end

  def title_tag(tag_key='title')
    "(#{tags[tag_key]})" if tags && !tags[tag_key].blank?
  end

  def last_name_first
    artist_arr = artist_name.split(' ')
    last_name = artist_arr.pop
    [last_name, artist_arr.join(' ')].join(', ')
  end

  def artist_params
    {'d_hsh'=>{
      'tagline'=> "#{tagline},",
      'body'=> "by #{formal_name}",
      'invoice_tagline'=> "#{abbrv_artist_name(artist_name.split(' '))},"},
    'attrs'=> {
      'artist'=> artist_name,
      'artist_id'=> artist_id}
    }
  end

  def abbrv_artist_name(artist_arr)
    if artist_arr.count == 2 && artist_arr[0].length>3
      "#{abbrv_first(artist_arr[0])} #{artist_arr[1]}"
    elsif artist_arr.count == 3
      "#{abbrv_first(artist_arr[0])} #{abbrv_first(artist_arr[1])} #{artist_arr[2]}"
    else
      artist_arr.join(' ')
    end
  end

  def abbrv_first(first_name)
    "#{first_name[0]}."
  end

  def sort_name
    artist_arr = artist_name.split(' ')
    last_name = artist_arr.pop
    sort_hsh={'sort_name'=> artist_arr.prepend(last_name).join(' ')}
    if self.tags.nil?
      self.tags = sort_hsh
    else
      self.tags.merge!(sort_hsh)
    end
  end

  # search v2 ##################################################################
  def self.search(scopes:, product_hattrs:, item_hattrs:, context: nil)
    #inputs = Product.search(scopes: scopes, product_hattrs: product_hattrs, context: context)

    inputs = Item.search(scopes: scopes, product_hattrs: product_hattrs, item_hattrs: item_hattrs, context: context)
    inputs[:artist][:opts] = [scopes[:artist]]
    inputs
  	#inputs = products_search(scopes, product_hattrs, scopes[:artist].products)
  	#inputs = Item.results_and_inputs(scopes[:product], scopes[:artist], scopes[:title], inputs[:product][:opts], valid_params(item_hattrs), item_hattrs, inputs)
  	#inputs
  end

  def self.products_search(scopes, product_hattrs, products, hstore='tags')
  	hattr_inputs = initialize_search_inputs(product_hattrs, products.pluck(hstore))
    #hattr_inputs = initialize_search_inputs(product_hattrs)
  	Product.config_hattrs_and_their_inputs(product_hattrs, hattr_inputs, products)
    puts "hattr_inputs: #{hattr_inputs}"
  	scope_inputs = config_scopes(scopes, products, valid_hattr_params(hattr_inputs), hstore)
    scope_inputs[:hattrs] = hattr_inputs #.merge!({:hattrs=>hattr_inputs})
    scope_inputs
  end

  def self.config_scopes(scopes, products, search_params, hstore)
  	scope_inputs = initialize_search_inputs(scopes)
  	products = search_query(products, search_params, hstore)
  	config_scope_inputs(scopes[:artist], products, scope_inputs)
  	scope_inputs
  end

  def self.config_scope_inputs(artist, products, inputs)
  	inputs[:product][:opts] = products
  	inputs[:artist][:opts] = [artist]
  	inputs[:title][:opts] = artist.titles
  end

  def self.item_search(product, artist, title, products, item_params, item_hattrs, inputs, hstore='csv_tags')
    hattr_inputs = initialize_search_inputs(item_hattrs)
    inputs[:items] = uniq_and_sorted_set(Item.item_results(product, artist, title, products, item_params, hstore), hstore, Item.table_keys)

    scope_inputs[:hattrs] = hattr_inputs #.merge!({:hattrs=>hattr_inputs})
    scope_inputs
  end

  # search v1 ##################################################################
  # def self.search(scopes:, product_hattrs:, item_hattrs:)
  # 	inputs = Product.initialize_scope_inputs(scopes).merge!({'hattrs'=>[]})
  # 	products = config_products(scopes[:product], scopes[:artist], Item.valid_params(product_hattrs))
  #
  #   config_scopes_and_their_inputs(scopes[:artist], products, inputs)
  # 	Product.config_hattrs_and_their_inputs(product_hattrs, product_hattrs, products, inputs)
  # 	items_and_inputs(scopes[:title], products, scopes[:artist].items, Item.valid_params(product_hattrs.merge!(item_hattrs)), item_hattrs, inputs)
  # 	inputs
  # end

  # def self.config_products(product, artist, search_params)
  # 	#products = product ? [product] : artist.products
  #   products = artist.products
  # 	products.any? ? Product.config_products(product, artist, products, search_params) : products
  # end

  # def self.config_scopes_and_their_inputs(artist, products, inputs)
  # 	inputs['product']['opts'] = products
  # 	inputs['artist']['opts'] = [artist]
  # 	inputs['title']['opts'] = artist.titles
  # end

  # def self.items_and_inputs(title, products, items, item_params, item_hattrs, inputs, hstore='csv_tags')
  # 	items = config_items(products, items, title, item_params, hstore, Item.table_keys)
  # 	items_tags = items.any? ? items.pluck(hstore) : []
  # 	config_scopes_hattrs_and_their_inputs(items, item_hattrs, items_tags, inputs)
  # end
  #
  # def self.config_items(products, items, title, item_params, hstore, table_keys)
  # 	return items if items.empty? && products.empty?
  # 	items = items.where(title: title) if title
  # 	items = Item.search_query(items, item_params, hstore) if item_params.any?
  # 	Item.uniq_and_sorted_set(items, hstore, Item.table_keys)
  # end
  #
  # def self.config_scopes_hattrs_and_their_inputs(items, item_hattrs, items_tags, inputs)
  # 	inputs['items'] = items
  # 	inputs['hattrs'].concat(Item.item_search_hattr_inputs(item_hattrs, items_tags))
  # end
  #
  # def self.item_opts(product, artist)
  # 	product && artist ? artist.product_items(product) : artist.items
  # end

  # COLLECTIONS ################################################################
  # artists ####################################################################
  # all artists (sorted)
  def self.sorted
    sorted_set(all)
  end

  def self.sorted_set(artists)
  	artists.order("artists.tags -> 'sort_name'")
  end
  # redundant: same as sorted
  def self.ordered_artists
    all.order("artists.tags -> 'sort_name'")
  end
  # all artists with items/products (sorted)
  def self.with_items
  	sorted_set(joins(:items)).uniq
  end

  # artists with these products (thru items)
  def self.with_these(products)
  	sorted_set(joins(:items).where(items: {id: Item.with_these(products)})).uniq
  end

  # items ######################################################################
  def items
    Item.joins(:artists).where(artists: {id: id})
  end

  def product_items(product)
    items.where(id: product.items).uniq
  end

  # products ###################################################################
  def products
    Product.where(id: items.includes(:products).map(&:products).flatten.uniq)
  end

  def has_any_of_these?(set)
  	products.any?{|product| set.include?(product)}
  end

  # titles #####################################################################
  def self.titles(artist, product=nil)
  	return [] if !artist
  	product ? product_items(product) : artist.titles
  end

  def titles
    items.pluck(:title).uniq.reject{|i| i.blank?}.sort
  end

end

#replace with above
# def titles(product)
#   (product ? product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
# end
#kill?
# def self.scoped_artists(products)
#   Artist.joins(:items).where(items: {id: Item.scoped_products(products)}).distinct
# end

# def items_scoped_by_artist_product_items(product)
#   items.where(id: product.items.ids)
# end
#
# def titles(product)
#   (product ? items_scoped_by_artist_product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
# end

# def title_tag
#   tags.try(:[], 'title_tag')
# end
