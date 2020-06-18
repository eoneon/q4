class Item < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  attribute :product
  attribute :options
  attribute :select_menus

  def product
    field_set = field_sets.detect{|field_set| field_set["tags"].keys.include?('medium')}
    field_set if field_set
  end

  def product_id
    product.id if product
  end

  def artist
    artists.first
  end

  def artist_id
    artist.id if artist
  end
end
