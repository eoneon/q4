module Draft
  def to_csv
    items = self.all
    #items = method_that_grabs_defined_set_of_items_scoped_by_skus(items)
    CSV.generate do |csv|
      csv << item.first.csv_tags.keys
      items.each do |item|
        csv << item.csv_tags.values if item.product
      end
    end
  end
end
