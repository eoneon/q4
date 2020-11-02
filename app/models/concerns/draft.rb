module Draft
  #def mounting_dimension(pg_hsh, store, hsh={'mounting'=>{}, 'dimension_for'=>{}, 'dimensions'=>{}})
  def mounting_dimension(pg_hsh, store, hsh={'dimensions'=>{}})
    build_dimension_params(pg_hsh['field_sets'], hsh['dimensions'])
    build_mounting_params(pg_hsh, hsh)
  end

  def build_dimension_params(fs_hsh, hsh)
    %w[mounting dimension].each do |k|
      extract_dimensions_from_tags(k, fs_hsh[k].dig('dimension', 'tags'), hsh)
    end
    hsh
  end

  def extract_dimensions_from_tags(tags, hsh, k)
    dimension_params(tags, k).each do |dimension_field, dimension_val|
      kind_key, dimension_field = dimension_field.split('_')
      assign_or_merge(hsh, kind_key, dimension_field, dimension_val)
    end
    hsh
  end

  def dimension_params(tags, kind)
    tags ? tags : default_dimension_params(kind)
  end

  def default_dimension_params(kind)
    keys = kind == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end

  def build_mounting_params(pg_hsh, hsh)
  end

  def mounting_dimension_hsh(pg_hsh, k, fk)
    if mounting_val = wrapped_context(nested_fname(pg_hsh['options'], 'material_id')) #gallery wrapped, stretched
      mounting_val

    elsif fs_opt_mounting = fs_opt_mounting(nested_fname(pg_hsh['field_sets'], k, 'options', fk)) #framed, custum framed
      fs_opt_mounting
    elsif fs_mounting = fs_mounting(nested_fname(pg_hsh['field_sets'], k, fk)) #border, matting
      fs_mounting
    elsif fs_dimension = fs_mounting(nested_fname(pg_hsh['field_sets'], 'dimension', fk)) #image
      fs_dimension
    end
  end

  def wrapped_context(material)
    wrapped_context_value(material) if material
  end

  def wrapped_context_value(material)
    if material.split(' ').include?('gallery')
      'gallery wrapped'
    elsif material.split(' ').include?('stretched')
      'stretched'
    end
  end

  def dimension_for(mounting_val)
    if mounting_val.split(' ').any? {|i| %w[gallery stretched].include?(i)}
      '(image)'
    end
  end

  # dimension_hsh ##############################################################



  def assign_or_merge(h, k,  k2, v)
    if h.has_key?(k)
      h[k].merge!({k2=>v})
    else
      h.merge!({k=>{k2=>v}})
    end
  end

  # dimension_hsh ##############################################################

  def export_dimensions(hsh, store, h={}, tag_set=[])
    hsh.each do |kind_key, dimensions|
      h.merge!(attr_dimensions(kind_key, dimensions))

      tag_set << format_dimensions(dimensions) + ' ' + "(#{dimension_type})" if dimensions.values.none?{|v| v.blank?}
    end
    hsh.each {|k,v| store['attrs'].merge!({k=>v})}
    detail_dimension(store, 'dimension', tag_set)
  end

  def attr_dimensions(kind_key, dimensions)
    if kind_key == 'mounting'
      attr_mounting_dimension(dimension_type, dimensions.transform_keys{|v| 'frame_'+v})
    else
      attr_material_dimension(dimensions)
    end
  end

  def attr_mounting_dimension(dimension_type, tags)
    dimension_type == 'frame' ? tags : tags.transform_values!{|v| nil}
  end

  def attr_material_dimension(tags)
    return tags if tags.keys == %w[width height]
    tag_vals = tags.values
    tag_vals.count == 1 ? %w[width height].map{|k| [k, tag_vals[0]]}.to_h : %w[width height].each_with_index{|(k,v), idx| [k, tag_vals[idx]]}.to_h
  end




end

# %w[mounting dimension].map{|k| hsh.merge!({k=>pg_hsh['field_sets'].dig(k, 'tags')})}
#
# material_dimension = pg_hsh['field_sets'].dig('dimension', 'tags')
# mounting_dimension = pg_hsh['field_sets'].dig('mounting', 'tags')
