class Category
  include Fieldable

  def category_params(category, medium, product_type, category_opt, store)
    store = kind_params(category, medium, product_type, category_opt, store)
    store = export_params(category, medium, product_type, store)
    store
  end

  def kind_params(category, medium, product_type, category_opt, store)
    category_hsh(category_opt).each do |k,v|
      param_merge(params: store, dig_set: dig_set(k: k, v: v, dig_keys: ['category']))
    end
    store
  end

  def export_params(category, medium, product_type, store)
    export_hsh(category, medium, product_type).each do |k,v|
      param_merge(params: store, dig_set: dig_set(k: k, v: v, dig_keys: %w[item export_params]))
    end
    store
  end

  def category_hsh(category_opt)
    body = body(category_opt)
    tagline = tagline(body)
    {'tagline'=> tagline, 'search_line'=> tagline, 'body'=> body}
  end

  def tagline(body)
    return if !body
    body == 'one-of-a-kind' ? 'One-of-a-Kind' : body.map{|word| word.capitalize}.join(' ')
  end

  def body(category_opt)
    category_opt unless category_opt == 'reproduction'
  end

  def export_hsh(category, medium, product_type)
    art_category = art_category(category, medium, product_type)
    art_type = art_type(art_category)
    {'art_category'=> art_category, 'art_type'=> art_type}
  end

  def art_category(category, medium, product_type)
    case
      when ['Original', 'OneOfAKind', 'OneOfOne', 'Production'].include?(category); 'Original'
      when ['LimitedEdition', 'UniqueVariation'].include?(category); 'Limited Edition'
      when category == 'Reproduction' && medium == 'Poster'; medium
      when category == 'Reproduction' && product_type == 'PrintMedia'; 'Print'
      when category == 'HandBlownGlass'; 'Hand Blown Glass'
    end
  end

  def art_type(art_category)
    case
      when art_category == 'Original'; 'Original Painting'
      when art_category == ['Limited Edition', 'Print', 'Poster']; 'Limited Edition'
      else art_category
    end
  end

end

#when category == 'Reproduction' && ['Poster', 'Sericel', 'Photograph'].include?(medium); medium
