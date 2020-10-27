class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  def self.product_items(artist_id)
    Item.joins(:item_groups).where(item_groups: {target_type: 'Artist', target_id: artist_id})
  end

  def self.tag_field_sets
    [%w[first_name middle_name last_name], %w[title_tag description_tag], %w[yob yod]]
  end
end
