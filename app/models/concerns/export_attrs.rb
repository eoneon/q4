require 'active_support/concern'

module ExportAttrs
  extend ActiveSupport::Concern

  class_methods do

    def to_csv(items)
      CSV.generate do |csv|
        csv << attr_keys
        items.each do |item|
          csv << map_attr_values(item.csv_tags) if item.product
        end
      end
    end

    def map_attr_values(csv_tags)
      attr_keys.map{|k| csv_tags[k]}
    end

    def attr_keys
      %w[sku artist_name artist_id title tagline property_room body width height frame_width frame_height retail qty]
    end

  end
end
