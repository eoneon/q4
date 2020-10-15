require 'active_support/concern'

module ExportAttrs
  extend ActiveSupport::Concern

  class_methods do
    def to_csv
      items = all
      #items = method_that_grabs_defined_set_of_items_scoped_by_skus(items)
      CSV.generate do |csv|
        csv << items.first.csv_tags.keys
        items.each do |item|
          csv << item.csv_tags.values if item.product
        end
      end
    end
  end
end
