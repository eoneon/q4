class Artist < ApplicationRecord
  include Search

  has_many :item_groups, as: :target
  has_many :items, through: :item_groups, source: :origin, source_type: "Item"

  validates :artist_name, presence: true
  validates :artist_id, presence: true
  validates :artist_id, uniqueness: true

  def formal_name
    [artist_name, life_span].compact.join(' ')
  end

  def description(name_tag)
    name_tag ? "#{formal_name} #{name_tag}" : formal_name
  end

  def life_span(tag_keys=%w[yob yod])
    "(#{tag_keys.map{|k| tags[k]}.join('-')})" if tags && tag_keys.all?{|k| !tags.dig(k).blank?}
  end

  def title_tag(tag_key='title')
    "(#{artist_tag(tag_key)})" if artist_tag(tag_key)
  end

  def body_tag(tag_key='body')
    artist_tag(tag_key)
  end

  def artist_tag(tag_key)
    tags[tag_key] if tags && !tags[tag_key].blank?
  end

  def last_name_first
    artist_arr = artist_name.split(' ')
    last_name = artist_arr.pop
    [last_name, artist_arr.join(' ')].join(', ')
  end

  def artist_params
    {'d_hsh'=>{
      'tagline'=> "#{description(title_tag)},",
      'body'=> "by #{description(body_tag)}",
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
    elsif artist_arr.count == 1
      artist_arr[0]
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
    inputs = Item.search(scopes: scopes, product_hattrs: product_hattrs, item_hattrs: item_hattrs, context: context)
    inputs[:artist][:opts] = [scopes[:artist]]
    inputs
  end

  # COLLECTIONS ################################################################
  # artists ####################################################################
  # all artists (sorted)
  def self.sorted
    sorted_set(all)
  end

  def self.sorted_set(artists)
  	artists.order("artists.tags -> 'sort_name'")
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

# redundant: same as sorted
# def self.ordered_artists
#   all.order("artists.tags -> 'sort_name'")
# end

#replace with above
# def titles(product)
#   (product ? product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
# end

# def titles(product)
#   (product ? items_scoped_by_artist_product_items(product) : items).pluck(:title).uniq.reject{|i| i.blank?}
# end

# def title_tag
#   tags.try(:[], 'title_tag')
# end
