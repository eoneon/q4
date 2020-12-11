class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  # def self.product_items(artist_id)
  #   Item.joins(:item_groups).where(item_groups: {target_type: 'Artist', target_id: artist_id})
  # end

  def self.tag_field_sets
    [%w[first_name middle_name last_name], %w[title_tag description_tag], %w[yob yod]]
  end

  def life_span
    v = %w[yob yod].map{|k| tags.try(:[], k)}.reject{|i| i.blank?}.join('-')
    "(#{v})" if v.present?
  end

  def yod
    v = tags.try(:[], 'yod')
    "(d.#{v})" if v.present?
  end

  def artist_tag
    [artist_name, life_span].compact.join(' ')
  end

  def artist_data
    {'artist_tag'=> artist_tag, 'yod'=> yod}.merge!(%w[last_name title_tag description_tag].map{|k| [k, tags.try(:[], k)]}.to_h)
  end
end
