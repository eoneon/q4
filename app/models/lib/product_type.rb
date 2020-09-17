class ProductType
  include Context

  # ProductType.media_sets
  def self.media_sets
    media_groups.map{|h| media_set_builder(h)}.flatten(1)
    disclaimer = Detail::Disclaimer.builder
    Product.all.map{|product| product.assoc_unless_included(disclaimer)}
  end

  def self.media_set_builder(media_set:, material_set:, prepend_set: [], append_set: [], insert_set: [], set: [], tags: {})
    media_set, material_set, prepend_set, append_set, insert_set = [media_set, material_set, prepend_set, append_set, insert_set].map{|arg| arg_as_arr(arg)}
    media_set.product(material_set).each do |option_set|
      kv_assign(tags, [['medium', option_set[0].klass_name], ['material', option_set[1].klass_name]])
      options = option_set_build(options: option_set, prepend_set: prepend_set, append_set: append_set, insert_set: insert_set)
      standard_product(product_name(tags), build_options(options), tags)
    end
  end

  def self.media_groups
    set=[]
    Medium::FSO.subclasses.each do |klass|
      cascade_merge(klass, set, {tags: klass.tags_hsh})
    end
    set
  end

  ###################################
  # product_name methods -> name_set.uniq.reject {|i| i.blank?}.join(" ")
  def self.product_name(tags, set=[])
    tags.each do |k,v|
      next if k == 'medium_category' || ['n/a', 'OnPaper', 'Standard', 'PrintMedia'].include?(v)
      set << build_name(k,v) unless set.include?(decamelize(v))
    end
    set.join(' ')
  end

  def self.build_name(k,v)
    if v == 'OneOfAKind'
      'One-of-a-Kind'
    elsif v == 'PaintingOnPaper'
      'Painting'
    else
      words = cap_words(decamelize(v)).split(' ').reject{|i| i == 'Standard'}.join(' ')
      k == "material" ? "on #{words}" : words
    end
  end

end
