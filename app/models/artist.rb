class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  ##############################################################################
  def self.tag_field_sets
    [%w[first_name last_name], %w[title_tag], %w[yob yod]]
  end

  def life_span
    v = %w[yob yod].map{|k| tags.try(:[], k)}.reject{|i| i.blank?}.join('-')
    "(#{v})" if v.present?
  end

  def yod
    v = tags.try(:[], 'yod')
    "(d.#{v})" if v.present?
  end

  def formal_name
    [artist_name, life_span].compact.join(' ')
  end

  def tagline
    name = formal_name
    title_tag ? "#{name} (#{title_tag})," : name
  end

  def search_line
    [tags.try(:[], 'last_name'), yod].compact.join(' ')
  end

  def title_tag
    tags.try(:[], 'title_tag')
  end

  def artist_params
    {'tagline'=> tagline, 'search_line'=> search_line, 'body'=> formal_name, 'export_tag'=> artist_name}
  end

end

# def self.tag_field_sets
#   [%w[first_name middle_name last_name], %w[tagline body], %w[yob yod]]
# end
#
# def artist_tag
#   [artist_name, life_span].compact.join(' ')
# end
#
# def artist_data
#   {'artist_tag'=> artist_tag, 'yod'=> yod}.merge!(%w[last_name tagline body].map{|k| [k, tags.try(:[], k)]}.to_h)
# end

# def export_headers
#   %w[tagline search_line body export_tag]
# end

# def artist_hsh
#   h = export_headers.each_with_object({}) do |k,h|
#     v =
#   end
# end

# def body_tag
#   tags.try(:[], 'body_tag')
# end

# def body
#   name = [artist_name, life_span].compact.join(' ')
#   body_tag ? "#{name}, #{body_tag}" : name
# end

# def self.product_items(artist_id)
#   Item.joins(:item_groups).where(item_groups: {target_type: 'Artist', target_id: artist_id})
# end
