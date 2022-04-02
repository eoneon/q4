class Artist < ApplicationRecord

  has_many :item_groups, as: :target
  has_many :items, through: :item_groups, source: :origin, source_type: "Item"
  #has_many :products, through: :item_groups, source: :target, source_type: "Product"

  def items
    Item.joins(:artists).where(artists: {id: id})
  end

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

  # COLLECTIONS ################################################################
  def self.sorted_set(artists)
  	artists.order("artists.tags -> 'sort_name'")
  end

  def self.sorted
    sorted_set(all)
  end

  def self.with_items
  	sorted_set(joins(:items)).uniq #.distinct #.order("artists.tags -> 'sort_name'")
  end

  def self.ordered_artists
    all.order("artists.tags -> 'sort_name'")
  end

  def self.with_these(products)
  	sorted_set(joins(:items).where(items: {id: Item.with_these(products)})).uniq #.distinct
    #sorted_set(joins(:items).where(items: {id: Item.scoped_products(products)})).uniq
  end

  def products
    Product.where(id: items.includes(:products).map(&:products).flatten.uniq)
    #Product.joins(:items).where(items: {id: items.ids}).distinct
  end

  #replace with above
  def product_items(product)
    items.where(id: product.items.ids)
  end
  #replace with above
  def titles(product)
    (product ? product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
  end
  #kill?


  def self.scoped_artists(products)
    Artist.joins(:items).where(items: {id: Item.scoped_products(products)}).distinct
  end
end


# def items_scoped_by_artist_product_items(product)
#   items.where(id: product.items.ids)
# end
#
# def titles(product)
#   (product ? items_scoped_by_artist_product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
# end

# def titles
#   items.pluck(:title).uniq.reject{|i| i.blank?}.sort
# end

# def title_tag
#   tags.try(:[], 'title_tag')
# end
