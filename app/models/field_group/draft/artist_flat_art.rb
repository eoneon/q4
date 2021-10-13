class ArtistFlatArt
  def material_dimensions(dimension, d_tag, d_tag2, attrs, args)
    if material_dimension = slice_and_delete(dimension, d_tag)
      # build_material_args
      material, mounting = material_dimension.to_a # [["WidthHeight", "(image)"], ["mounting_width_height", "n/a"]]
      dimension_keys = material[0].underscore.split('_')
      material_tag = material_tag(dimension, dimension_keys, material[1], args)
      # build_material_dimensions
      if material_dimensions = slice_dimensions(dimension, dimension_keys)
        args[:material_dimensions] = dimension_description_params(material_dimensions.values, (dimension_keys[0]=='diameter'), material_tag)
        attrs.merge!([%w[width height], args[:material_dimensions].values[0..1]].transpose.to_h)
        if mounting
          # build_material_dimensions
          mounting_dimensions(dimension, mounting_dimension_keys(mounting[0].split('_')), dimension[d_tag2])
        end
      end
    end
  end

  # def material_dimensions(dimension, attrs, args)
  #   if material_dimension = slice_and_delete(dimension, args[:d_tag])
  #     build_material_and_mounting_args(dimension, material_dimension, args)
  #     if material_dimensions = slice_dimensions(dimension, args[:dimension_keys])
  #       build_material_dimensions(material_dimensions.values, attrs, args)
  #       if mounting_dimensions = slice_dimensions(dimension, mounting_dimension_keys)
  #       end
  #     end
  #   end
  # end

  # def build_material_and_mounting_args(dimension, material_dimension, args)
  #   material, mounting = material_dimension.to_a
  #   args[:dimension_keys] = material[0].underscore.split('_')
  #   args[:material_tag] = material_tag(dimension, material[1], args)
  #   build_mounting_args(dimension, mounting, args)
  # end
  #4
  def dimension_params(dimension, f_grp, args)
    if build_material_and_mounting_dimensions(dimension, attrs, args)
      tb_dimensions(args[:k], args[:material_dimensions], args[:mounting_dimensions], f_grp[:store])
    end
  end

  #10 -> 36
  def build_material_and_mounting_dimensions(dimension, attrs, args)
    build_material_and_mounting_args(dimension, attrs, args)
    if material_dimensions = slice_dimensions(dimension, args[:material_dimension_keys])
      build_material_dimensions(material_dimensions.values, attrs, args)
      if mounting_dimensions = slice_dimensions(dimension, args[:mounting_dimension_keys])
        build_mounting_dimensions(dimension, mounting_dimensions.values, attrs, args)
      end
      args
    end
  end
  #4
  def build_material_dimensions(material_dimension_values, attrs, args)
    args[:material_dimensions] = dimension_description_params(material_dimension_values, (args[:material_dimension_keys][0]=='diameter'), args[:material_tag])
    attrs.merge!([%w[width height], args[:material_dimensions].values[0..1]].transpose.to_h)
  end
  #4
  def build_mounting_dimensions(dimension, mounting_dimensions_values, attrs, args)
    args[:mounting_dimensions] = dimension_description_params(mounting_dimensions_values, nil, args[:mounting_tag])
    attrs.merge!([%w[frame_width frame_height], mounting_dimensions_values[0..1]].transpose.to_h) if args[:mounting_tag]=='(frame)'
  end
  #9
  def build_material_and_mounting_args(dimension, attrs, args)
    if material_dimension = slice_and_delete(dimension, args[:d_tag])
      material, mounting = material_dimension.to_a
      build_material_args(material, args)
      if mounting_dimension = slice_and_delete(dimension, args[:d_tag2])
        build_mounting_args(dimension, mounting_dimension, mounting, args)
      end
    end
  end
  #4
  def build_material_args(material, args)
    args[:material_dimension_keys] = material[0].underscore.split('_')
    args[:material_tag] = material_tag(dimension, material[1], args)
  end
  #5
  def build_mounting_args(dimension, mounting_dimension, mounting, args)
    if args[:mounting_tag] = mounting_dimension.dig(args[:d_tag2])
      args[:mounting_dimension_keys] = mounting_dimension_keys(mounting[0].split('_'))
    end
  end



  # def build_material_and_mounting_args(dimension, material_dimension, args)
  #   material, mounting = material_dimension.to_a
  #   build_material_args(material, args)
  #   if mounting_dimension = slice_and_delete(dimension, args[:d_tag2])
  #     build_mounting_args(dimension, mounting_dimension, mounting, args)
  #   end
  # end



  # def build_mounting_args(dimension, mounting, args)
  #   if mounting_dimension = slice_and_delete(dimension, args[:d_tag2])
  #     if material_dimensions = slice_dimensions(dimension, mounting_dimension_keys(mounting[0].split('_')))
  #       args[:mounting_tag]   = mounting_dimension.dig(args[:d_tag2])
  #       args[:mounting_dimensions] = dimension_description_params(mounting_dimensions.values, nil, mounting_dimension.dig(args[:d_tag2]))
  #     end
  #   end
  # end

  # def build_material_dimensions(material_dimension_values, attrs, args)
  #   args[:material_dimensions] = dimension_description_params(material_dimension_values, (args[:dimension_keys][0]=='diameter'), args[:material_tag])
  #   attrs.merge!([%w[width height], args[:material_dimensions].values[0..1]].transpose.to_h)
  # end

  # def mounting_dimensions(dimension, mounting_dimension_keys, mounting_tag, attrs, args)
  #   if mounting_dimensions = slice_dimensions(dimension, mounting_dimension_keys)
  #     args[:mounting_dimensions] = dimension_description_params(mounting_dimensions.values, nil, mounting_tag)
  #     attrs.merge!([%w[frame_width frame_height], mounting_dimensions.values[0..1]].transpose.to_h) if mounting_tag=='(frame)'
  #   end
  # end

  # 12 + 7 + 3: 22 material_dimension = {"WidthHeight"=>"(image)", "mounting_width_height"=>"n/a"}
  def material_dimensions(dimension, d_tag, attrs, args)
    if material_dimension = slice_and_delete(dimension, d_tag)
      material, mounting = material_dimension.to_a # [["WidthHeight", "(image)"], ["mounting_width_height", "n/a"]]
      dimension_keys = material[0].underscore.split('_')
      material_tag = material_tag(dimension, dimension_keys, material[1], args)
      if material_dimensions = slice_dimensions(dimension, dimension_keys)
        args[:material_dimensions] = dimension_description_params(material_dimensions.values, (dimension_keys[0]=='diameter'), material_tag)
        attrs.merge!([%w[width height], args[:material_dimensions].values[0..1]].transpose.to_h)
        args[:mounting_dimension_keys] = mounting_dimension_keys(mounting[0].split('_')) if mounting
      end
    end
  end

  def material_tag(dimension, material, args)
    if weight_key = slice_and_delete(args[:dimension_keys], 'weight')
      weight_params(dimension, weight_key)
    else
      material
    end
  end

  # def material_tag(dimension, dimension_keys, material, args)
  #   if weight_key = slice_and_delete(dimension_keys, 'weight')
  #     weight_params(dimension, weight_key)
  #   else
  #     material
  #   end
  # end

  def mounting_dimension_keys(mounting_keys)
    mounting_keys[1..-1].map{|d_name| [mounting_keys[0], d_name].join('_')}
  end

  def mounting_dimensions(dimension, d_tag, attrs, args)
    if mounting_dimension = slice_and_delete(dimension, d_tag)
      if mounting_dimensions = slice_dimensions(dimension, args[:mounting_dimension_keys])
        args[:mounting_dimensions] = dimension_description_params(mounting_dimensions.values, nil, mounting_dimension[d_tag])
        puts "mounting_dimensions_a: #{args[:mounting_dimensions]}"
        attrs.merge!([%w[frame_width frame_height], mounting_dimensions.values[0..1]].transpose.to_h) if mounting_dimension[d_tag]=='(frame)'
      end
    end
  end

end
