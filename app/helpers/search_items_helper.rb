module SearchItemsHelper

  def search_tags
    {'search_tagline'=>{'label'=>'tagline', 'col'=>'col-4'}, 'mounting'=>{'label'=>'mounting', 'col'=>'col-2'}, 'material_dimensions'=>{'label'=>'dimensions', 'col'=>'col-2'}, 'edition'=>{'label'=>'edition', 'col'=>'col-1'}}
  end

  def product_item_media(csv_tags, rows=[])
    Item.item_search_keys.each do |k|
      rows << csv_tags.dig(k)
    end
    rows
  end

  def search_cols(csv_tags, cols=[])
    search_tags.each do |k,h|
      cols << {'col'=> h['col'], 'cell'=> csv_tags.dig(k)}
    end
    cols
  end

  def format_options(klass, attr)
    klass.all.collect{|obj| [obj.public_send(attr), obj.id]}
  end

end
