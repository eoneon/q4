require 'active_support/concern'

module ExportAttrs
  extend ActiveSupport::Concern

  # csv ######################################################################## Item.find(5).export_hsh
  def export_values
    Item.csv_sorted_keys.map{|k| export_hsh[k]}
  end

  def export_hsh(csv_hsh={})
    [csv_items, csv_dimensions, csv_media, csv_artist].map{|h| csv_hsh.merge!(h)}
    csv_hsh
  end

  # kill #######################################################################
  # csv_item_keys
  def csv_items
    #%w[sku title retail qty].map{|k| [k, public_send(k)]}.to_h
    csv_target_keys('item').map{|k| [k, public_send(k)]}.to_h
  end
  # csv_artist_keys
  def csv_artist
    %w[artist_name artist_id].map{|k| [k, csv_artist_val(k)]}.to_h
  end

  def csv_artist_val(k)
    artist ? artist.public_send(k) : nil
  end

  # end of kill #######################################################################

  def csv_dimensions
    %w[material_width material_height mounting_width mounting_height].map {|k| format_csv_dimension_hsh(k.split('_'), tags.try(:[], k))}.to_h
  end

  def format_csv_dimension_hsh(split_key, val)
    kind, dimension = split_key
    [csv_dimension_key(dimension, kind), csv_dimension_val(kind, val)]
  end

  def csv_dimension_key(dimension, kind)
    kind == 'material' ? dimension : ['frame', dimension].join('_')
  end

  def csv_dimension_val(kind, val)
    return if val.nil?
    kind == 'material' ? val.to_i : frame_dimensions(val)
  end

  def frame_dimensions(val)
    val.to_i if field_targets.detect {|f| f.field_name == 'framing'}
  end

  # csv media field attrs ######################################################
  # csv_media_keys
  def csv_media(csv_hsh={})
    %w[category medium material].each do |k|
      csv_hsh.merge!(media_case(k, product.tags[k]))
    end
    csv_hsh
  end

  def media_case(k, v)
    if k == 'category'
      [%w[art_type, art_category], category_case(v)].transpose.to_h
    elsif k == 'medium'
      {k => medium_case(v)}
    elsif k == 'material'
      {k => material_case(v.underscore.split('_'))}
    end
  end

  def category_case(v)
    if ['Original', 'OneOfAKind'].include?(v)
      ['Original', 'Original Painting']
    elsif v == 'LimitedEdition'
      ['Limited Edition', 'Limited Edition']
    elsif v == 'PrintMedia'
      ['Print', 'Limited Edition']
    end
  end

  def material_case(material_split)
    case
      when material_split.include?('canvas'); 'Canvas'
      when material_split.include?('paper'); 'Paper'
      when material_split.include?('wood') || material_split.include?('acrylic'); 'Board'
      when material_split.include?('metal'); 'Metal'
      when material_split.include?('sericel'); 'Sericel'
    end
  end

  def medium_case(medium)
    if medium = %w[painting drawing].detect {|k| medium.underscore.split('_').include?(k)}
      field_name = field_targets.select{|f| f.kind == 'medium'}[0].try(:field_name)
      return 'Unknown' if field_name.blank? || field_name == 'painting'
      public_send(medium+'_option_case', field_name.split(' ')[0])
    else
      medium_option_case(medium)
    end
  end

  def medium_option_case(medium)
    case
      when ['BasicMixedMedia', 'AcrylicMixedMedia', 'Relief'].include?(medium); 'Mixed Media'
      when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(medium); medium
      when medium == 'Silkscreen'; 'Serigraph'
    end
  end

  def painting_option_case(medium)
    case
      when %w[oil acrylic watercolor pastel guache].include?(medium); medium.capitalize
      when medium == 'mixed'; 'Mixed Media'
      when medium == 'sumi-ink'; 'Watercolor'
    end
  end

  # csv ########################################################################
  class_methods do

    def to_csv
      items = self.all
      CSV.generate do |csv|
        csv << csv_sorted_keys
        items.each do |item|
          csv << item.export_values if item.product
        end
      end
    end

    def csv_sorted_keys
      %w[item artist dimension media description].map{|k| csv_target_key_set(k)}.flatten(1).sort {|a,b| a[0] <=> b[0]}.map{|set| set[1]}
    end

    def csv_product_keys
      %w[media dimension description].map{|k| csv_target_key_set(k)}.flatten(1).map{|set| set[1]}
    end

    def csv_target_keys(target)
      csv_target_key_set(target).map{|set| set[1]}
    end

    def csv_target_key_set(target)
      public_send(['csv', target, 'keys'].join('_'))
    end

    def get_key_set(key_sets)
      key_sets.map{|set| set[1]}
    end

    def csv_item_keys
      [[0, 'sku'], [3, 'title'], [7, 'retail'], [8, 'qty']]
    end

    def csv_artist_keys
      [[1, 'artist_name'], [2, 'artist_id']]
    end

    def csv_dimension_keys
      [[12, 'width'], [13, 'height'], [14, 'frame_width'], [15, 'frame_height']]
    end

    def csv_media_keys
      [[9, 'art_type'], [10, 'art_category'], [11, 'medium'], [12, 'material']]
    end

    def csv_description_keys
      [[4, 'tag_line'], [5, 'property_room'], [6, 'description']]
    end

  end
end

# def csv_sorted_keys
#   %w[sku artist_name artist_id title tag_line property_room description retail qty art_type art_category medium material width height frame_width frame_height]
# end
