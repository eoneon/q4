module Draft
  # => {"dimensions"=>{"mounting"=>{"width"=>"30", "height"=>"30"}, "material"=>{"width"=>"25", "height"=>"25"}}, "mounting_ref"=>{"mounting"=>"framed", "material"=>"width & height"}, "dimension_for"=>{"mounting"=>"frame", "material"=>"image"}}
  #hsh['dimensions'][k] => {"width"=>"30", "height"=>"30"}

  #####################################################
  def detail_dimension(hsh, h={'measurements'=>[]})
    hsh['dimensions'].each do |k, dimensions|
      next if dimensions.values.any?{|i| i.nil?}
      measurements = format_dimensions(dimensions.values)
      dimension_for = hsh['dimension_for'][k]
      #h['mounting']
      h['measurements'] << "#{measurements} (#{dimension_for})"
      h['display_size'] = "(#{measurements})" if k == 'material'
      oversized_dimensions(dimensions.values, measurements, dimension_for, k, h)
    end
    h
  end

  def oversized_dimensions(dimension_vals, measurements, dimension_for, k, h)
    if dimension_vals.all?{|i| i.to_i >= 40}
      h['oversized'] = "(#{measurements})" if oversized?(dimension_for, k)
    end
  end

  def oversized?(dimension_for, k)
    k == 'mounting' && dimension_for.any?{|i| %w[frame matting].include?(i)} || k == 'material' && !framed?(dimension_for)
  end

  def framed?(dimension_for)
    'framed' if dimension_for == 'frame'
  end

  def detail_dimension(dimensions_vals, dimension_for, store, k='dimension')
    punct = tag_set.count > 1 ? ', ' : ' '
    #store['search_tagline'].merge!({k => tag_set})
    store['body'].merge!({k=> "Measures approx. #{tag_set.join(punct)}."})
  end

  def detail_mounting(k, mounting, dimension_for store)
    mounting_val = dimension_for == 'frame' ? 'framed' : mounting
    store['tagline'].merge!({k=> mounting_val}) if mounting_val == 'framed'
    store['search_tagline'].merge!({k=> "(#{mounting_val})"}) if mounting_val
    store['body'].merge!({k=>"This piece comes #{mounting}."}) if mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  end

  def format_detail_mounting(mounting, dimension_for)
    dimension_for == 'frame' ? 'framed' : mounting
  end



  #####################################################

  def format_body_dimensions(hsh, k)
    assign_or_merge(hsh, 'body', k, format_dimensions(hsh['dimensions'][k].select{|k,v| k != 'dimension_for'}))
  end
end
