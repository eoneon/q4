require 'active_support/concern'

module ExportAttrs
  extend ActiveSupport::Concern

  def csv_export_attrs
    %w[sku artist artist_id title retail width height frame_width frame_height tagline property_room description art_type art_category material medium qty]
  end

  class_methods do

    def to_csv(items)
      CSV.generate do |csv|
        csv << csv_headers
        items.each do |item|
          next unless item.product
          item.csv_tags["title"] = item.csv_tags["title"].gsub(/"/,'')
          csv << Item.new.csv_export_attrs.map{|k| item.csv_tags[k]}
        end
      end
    end

    def csv_headers
      ['SKU', 'ARTIST', 'ARTIST ID', 'TITLE', 'RETAIL', 'WIDTH', 'HEIGHT', 'FRAME WIDTH', 'FRAME HEIGHT', 'TAG', 'PR TAG', 'DESCRIPTION', 'ART TYPE', 'ITEM CAT', 'MATERIAL', 'MEDIUM', 'QTY']
    end

  end
end
