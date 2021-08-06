class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  def self.tag_field_sets
    [%w[first_name last_name], %w[title_tag], %w[yob yod]]
  end

  def formal_name
    [artist_name, life_span].compact.join(' ')
  end

  def tagline
    title_tag ? "#{formal_name} #{title_tag}," : formal_name
  end

  def life_span(tag_keys=%w[yob yod])
    "(#{tag_keys.map{|k| tags[k]}.join('-')})" if tags &&  tag_keys.all?{|k| !tags.dig(k).blank?}
  end

  def title_tag(tag_key='title_tag')
    "(#{tags[tag_key]})" if tags && !tags[tag_key].blank?
  end

  def artist_params
    {'d_hsh'=>{'tagline'=> tagline, 'body'=> formal_name}, 'attrs'=> {'artist'=> artist_name, 'artist_id'=> artist_id}}
  end

end

# def title_tag
#   tags.try(:[], 'title_tag')
# end

# def yod
#   v = tags.try(:[], 'yod')
#   "(d.#{v})" if v.present?
# end

# def search_line
#   [tags.try(:[], 'last_name'), yod].compact.join(' ')
# end

# def artist_params
#   {'tagline'=> tagline, 'search_line'=> search_line, 'body'=> formal_name, 'export_tag'=> artist_name}
# end
