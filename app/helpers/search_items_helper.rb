module SearchItemsHelper

  def search_label(input_name)
    input_name[0..2]+':'
  end

  def attr_tags
    {'search_tagline'=>{'label'=>'tagline', 'col'=>'col-2'}, 'mounting_search'=>{'label'=>'mounting', 'col'=>'col-2'}, 'measurements'=>{'label'=>'dimensions', 'col'=>'col-2'}}
  end

  def attr_tags_for_table
    {'search_tagline'=>{'label'=>'tagline', 'col'=>'col-8'}, 'measurements'=>{'label'=>'dimensions', 'col'=>'col-2'}, 'mounting_search'=>{'label'=>'mounting', 'col'=>'col-2'}}
  end

  def product_item_media(tags, rows=[])
    Item.sort_keys[0..-2].each do |k|
      rows << tags.dig(k)
    end
    rows
  end

  def search_cols(tags)
    attr_tags_for_table.each_with_object([]) do |(k,input_hsh), cols|
      cols << {'col'=> input_hsh['col'], 'table-data'=> tags.dig(k)}
    end
  end

  def format_options(klass, attr)
    klass.all.collect{|obj| [obj.public_send(attr), obj.id]}
  end

  # def abbrv_attr_tags(table_data)
  #   table_data == 'gallery wrapped' ? 'wrapped' : table_data
  # end

end

# def attr_tags
#   {'search_tagline'=>{'label'=>'tagline', 'col'=>'col-2'}, 'mounting'=>{'label'=>'mounting', 'col'=>'col-2'}, 'material_dimensions'=>{'label'=>'dimensions', 'col'=>'col-2'}, 'edition'=>{'label'=>'edition', 'col'=>'col-1'}}
# end
#
# def attr_tags_for_table
#   {'search_tagline'=>{'label'=>'tagline', 'col'=>'col-8'}, 'mounting'=>{'label'=>'mounting', 'col'=>'col-1'}, 'material_dimensions'=>{'label'=>'dimensions', 'col'=>'col-2'}, 'edition'=>{'label'=>'edition', 'col'=>'col-1'}}
# end

# def product_item_media(csv_tags, rows=[])
#   Item.item_search_keys.each do |k|
#     rows << csv_tags.dig(k)
#   end
#   rows
# end
#
# def search_cols(csv_tags, cols=[])
#   attr_tags_for_table.each do |k,h|
#     cols << {'col'=> h['col'], 'table-data'=> csv_tags.dig(k)}
#   end
#   cols
# end
