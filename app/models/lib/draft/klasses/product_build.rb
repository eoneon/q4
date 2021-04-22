module ProductBuild

  def field_order
    [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate]
  end

  def build_product(p, tags, product={})
    product['options'] = sort_fields(p)
    product['tags'] = build_tags(p, tags)
    product['name'] = product_name(product['tags'])
    Product.builder({product_name: product['name'], options: product['options'], tags: product['tags']})
  end

  def sort_fields(p)
    p_set = field_order.each_with_object([]) do |k, p_set|
      p_set << p[k] if p.has_key?(k)
    end
  end

  def build_tags(p, tags)
    tags = tag_keys.each_with_object(tags) do |k,tags|
      tags[k.to_s.underscore] = p[k].field_name if p.has_key?(k)
    end
  end

  def product_name(tags)
    format_name(edit_name(name_set(tags).join(' ')))
  end

  def format_name(name)
    name.split(' ').map(&:strip).join(' ')
  end

  def edit_name(name)
    name = [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['One Of One', 'One-of-One']].each_with_object(name) do |word_set|
      name.sub!(word_set[0], word_set[1])
    end
  end

  def class_to_cap(class_word)
    class_word.underscore.split('_').map{|word| word.capitalize}.join(' ')
  end

  def name_keys
    tag_keys.map{|k| k.to_s.underscore}
  end
end
