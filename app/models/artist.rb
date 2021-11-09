class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  def self.tag_field_sets
    [%w[first_name last_name], %w[title_tag], %w[yob yod]]
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

  def title_tag(tag_key='title_tag')
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
    last_name = artist_arr.unshift
    sort_hsh={'sort_name'=> artist_arr.prepend(last_name).join(' ')}
    #sort_hsh={'sort_name'=> artist_name.split(' ').last} #last_name
    if self.tags.nil?
      self.tags = sort_hsh
    else
      self.tags.merge!(sort_hsh)
    end
  end

end

# def sort_name(artist_arr)
#   if artist_arr.count == 2
#     {'first_name'=> artist_arr[0], 'last_name'=> artist_arr[1]}
#   elsif artist_arr.count > 2
#     last_name = artist_arr.unshift
#     {'first_name'=> artist_arr.join(' '), 'last_name'=> last_name}
#   elsif artist_arr.count == 1
#     {'last_name'=> artist_arr[0]}
#   end
# end

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
