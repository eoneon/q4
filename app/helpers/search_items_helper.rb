module SearchItemsHelper
  
  def inputs_and_options(items, h={})
    Item.item_search_keys.each do |k|
      h.merge!({k=> items.map{|item| item.csv_tags[k]}.uniq.compact})
    end
    h
  end

  def product_item_media(csv_tags, rows=[])
    Item.item_search_keys.each do |k|
      rows << csv_tags.dig(k)
    end
    rows
  end

end
