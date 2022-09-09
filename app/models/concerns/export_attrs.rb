require 'active_support/concern'

module ExportAttrs
  extend ActiveSupport::Concern

  def csv_export_keys
    %w[sku artist artist_id title retail width height frame_width frame_height tagline property_room description art_type art_category material medium qty]
  end

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
      Item.new.csv_export_keys #contexts[:csv][:export]
    end

  end
end
