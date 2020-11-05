class Export

  ####################### h = Export.new.csv_test(6)  <!--> Item.find(5).product_group['params']['field_sets']  h = Item.find(5).product_group['params']['options']
  def csv_test(i, store={'attrs'=>{}, 'tagline'=>{}, 'search_tagline'=>{}, 'body'=>{}})
    pg_hsh = Item.find(i).product_group['params']
    mounting_dimension(pg_hsh, store)
    store
  end

  # export_params ##############################################################
  def export_params(item, product, artist, pg_hsh, store={'attrs'=>{}, 'tagline'=>{}, 'search_tagline'=>{}, 'body'=>{}})
    csv_values_from_item(item, artist, store)
    csv_values_from_params(product, pg_hsh, store)
  end

  # csv_values_from_item #######################################################
  def csv_values_from_item(item, artist, store, hsh={'item'=>{}})
    build_item_params(item, artist, store, hsh['item'])
  end

  def build_item_params(item, artist, store, i_hsh)
    i_hsh.merge!(csv_attr_and_val(item, 'item').merge(csv_attr_and_val(artist, 'artist')))
    i_hsh['title'] = i_hsh['title'].blank? ? 'Untitled' : i_hsh['title']
    export_item(i_hsh, store)
    i_hsh
  end

  def export_item(i_hsh, store)
    i_hsh.each do |k,v|
      store['attrs'].merge!({k=>v})
      description_hsh(store,k,v) if %w[title artist_name].include?(k)
    end
    store
  end

  # csv_values_from_params #####################################################
  def csv_values_from_params(product, pg_hsh, store)
    return store['attrs'].merge!(default_attr_media) if product.nil?
    csv_values_from_product_and_options(product, build_options(pg_hsh['options']), store)
    csv_values_from_field_sets(pg_hsh, store)
    format_description(store)
  end

  def csv_values_from_product_and_options(product, options, store)
    product_hsh = product_hsh(product, options)
    export_product_media(product_hsh, store)
    opt_media_hsh(options, product_hsh, store)
  end

  def csv_values_from_field_sets(pg_hsh, store)
    mounting_dimension_hsh(pg_hsh, store)
    fs_opt_media(pg_hsh['field_sets'], store)
    detail_numbering(pg_hsh['field_sets'], 'numbering', store)
  end

  # description_hsh ############################################################
  def description_hsh(store,k,v)
    return if v.blank?
    description_case(store,k,v)
  end

  def description_case(store,k,v)
    case
      when k == 'title'; detail_title(store,k,v)
      when k == 'artist_name'; detail_artist(store,k,v)
      when k == 'category' && v == 'one of a kind';  detail_category(store,k,v)
      when k == 'material'; detail_material(store,k,v)
      when k == 'signature'; detail_signature(store,k,v)
      when k == 'certificate'; detail_certificate(store,k,v)
      else default_detail(store,k,v)
    end
  end

  def detail_title(store,k,v)
    title = v == 'Untitled' ? 'This' : "\"#{v}\""
    store['tagline'].merge!({k=>title}) if title != 'This'
    #store['search_tagline'].merge!({k=>title}) if title != 'This'
    store['body'].merge!({k=>title})
  end

  def detail_artist(store,k,v)
    store['tagline'].merge!({k=> "#{v},"})
    store['body'].merge!({k=> "by #{v},"})
  end

  def detail_category(store, k, v)
    store['tagline'].merge!({k=>'One-of-a-Kind'})
    store['search_tagline'].merge!({k=>'One-of-a-Kind'})
    store['body'].merge!({k=>'one-of-a-kind'})
  end

  def detail_material(store,k,v)
    return if v == 'Sericel'
    store['tagline'].merge!({k => "on #{tagline_material_value(v)}"}) if store['attrs']['material'] != 'Paper'
    store['search_tagline'].merge!({k => "on #{v}"})
    store['body'].merge!({k => "on #{body_material_value(v)}"})
  end

  # def detail_mounting(k, mounting, store)
  #   store['tagline'].merge!({k=>'framed'}) if mounting.split(' ').include?('framed')
  #   store['search_tagline'].merge!({k=> "(#{mounting})"}) if mounting.split(' ').any?{|i| %w[framed matted border].include?(i)}
  #   store['body'].merge!({k=>"This piece comes #{mounting}."}) if mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  # end
  #
  # def detail_dimension(store, k, tag_set)
  #   return if tag_set.empty?
  #   punct = tag_set.count > 1 ? ', ' : ' '
  #   #store['search_tagline'].merge!({k => tag_set})
  #   store['body'].merge!({k=> "Measures approx. #{tag_set.join(punct)}."})
  # end

  def detail_signature(store, k, v)
    store['tagline'].merge!({k=>tagline_signature(v)})
    store['search_tagline'].merge!({k=> store['tagline'][k]})
    store['body'].merge!({k=>body_signature(v)})
  end

  def detail_certificate(store, k, v)
    store['search_tagline'].merge!({k =>"with #{v}"})
    v = v == 'LOA' ? 'Letter' : 'Certificate'
    store['tagline'].merge!({k=> "with #{v} of Authenticity."})
    store['body'].merge!({k=> "Includes #{v} of Authenticity."})
  end

  def detail_numbering(fs_hsh, k, store)
    numbering, opt_numbering, tags = fs_hsh.dig(k, k+'_id').try(:field_name), fs_hsh.dig(k, 'options', k+'_id').try(:field_name), fs_hsh.dig(k, 'tags')
    return if !numbering || !opt_numbering

    numbering_value = numbering_value(numbering, opt_numbering, tags)
    store['tagline'].merge!({k=> numbering_value})
    store['search_tagline'].merge!({k => opt_numbering}) #abbrv later?
    store['body'].merge!({k=> numbering_value})
  end

  def default_detail(store,k,v)
    store['tagline'].merge!({k=>v.split(' ').map{|k| k.capitalize}.join(' ')})
    store['search_tagline'].merge!({k=>store['tagline'][k]})
    store['body'].merge!({k=>v})
  end

  # product_hsh ################################################################ => {"product"=>{"category"=>"Original", "medium"=>"Painting", "material"=>"Board"}}
  def attr_product_media_case(k, v)
    if k == 'category'
      attr_category(v)
    elsif k == 'medium'
      {k=>attr_medium(v)}
    elsif k == 'material'
      {k=>attr_material(v)}
    else
      {k=>v}
    end
  end

  def attr_category(v)
    [%w[art_type, art_category], attr_category_case(v)].transpose.to_h
  end

  def attr_category_case(v)
    if ['Original', 'OneOfAKind'].include?(v)
      ['Original', 'Original Painting']
    elsif v == 'LimitedEdition'
      ['Limited Edition', 'Limited Edition']
    elsif v == 'PrintMedia'
      ['Print', 'Limited Edition']
    end
  end

  def attr_medium(medium)
    case
      when medium == 'Painting'; attr_painting(medium).capitalize
      when medium == 'Drawing'; attr_drawing(medium)
      else medium
    end
  end

  def attr_painting(medium)
    case medium
      when medium == 'painting'; 'unknown'
      when medium == 'sumi ink painting'; 'watercolor'
      else %w[oil acrylic watercolor pastel guache].detect {|k| medium == "#{k} painting"}
    end
  end

  def attr_drawing(medium)
    if medium.split(' ').include?('pencil')
      'Pencil'
    else
      'Pen and Ink'
    end
  end

  def attr_material(material)
    if k = %w[canvas paper board metal sericel].detect{|k| material.underscore.split('_').include?(k)}
      k.capitalize
    else
      'Board'
    end
  end

  def product_keys
    %w[category sub_category medium material]
  end

  # # refactor mounting_dimension_hsh #####################################################
  def mounting_dimension(pg_hsh, store)
    build_mounting_dimension(pg_hsh, hsh={'dimensions'=>{}, 'mounting_ref'=>{}, 'dimension_for'=>{}})
    attr_dimensions(hsh['dimensions'], store)
    detail_mounting_dimension(hsh, store)
  end

  def detail_mounting(hsh, store, k='mounting')
    store['tagline'].merge!({k=> hsh['framed']}) if hsh['framed']
    store['search_tagline'].merge!({k=> "(#{hsh[k]})"}) if hsh[k].split(' ').any?{|i| %w[framed matted border].include?(i)}
    store['body'].merge!({k=>"This piece comes #{hsh[k]}."}) if hsh[k].split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  end

  def detail_dimension(hsh, store, k='dimension')
    store['tagline'].merge!({k=> hsh['oversized']}) if hsh['oversized']
    store['search_tagline'].merge!({k=> hsh['display_size']}) if hsh['display_size']
    store['body'].merge!({k=> "Measures approx. #{hsh['measurements'].join(', ')}."})
  end

  def detail_mounting_dimension(hsh, store)
    hsh = build_detail_mounting_dimension(hsh)
    detail_mounting(hsh, store)
    detail_dimension(hsh, store)
  end

  def build_mounting_dimension(pg_hsh, hsh)
    %w[mounting dimension].each do |k|
      new_key, dimension_params = k == 'dimension' ? 'material' : k, dimension_params(pg_hsh.dig('field_sets', k, 'tags'), k)
      build_dimensions(dimension_params, hsh['dimensions'])
      build_mounting(pg_hsh, k, new_key, k+'_id', hsh)
    end
    hsh
  end

  def attr_dimensions(hsh, store)
    hsh.each do |k, dimensions|
      dimensions = format_attr_dimensions(k, dimensions)
      store['attrs'].merge!(build_attr_dimensions(dimensions, dimensions.values.take(2), attr_dimension_keys(k)))
    end
  end

  def build_detail_mounting_dimension(hsh, h={'measurements'=>[]})
    hsh['dimensions'].each do |k, dimensions|
      next if dimensions.values.any?{|i| i.nil?}
      measurements, dimension_for = format_dimensions(dimensions.values), hsh['dimension_for'][k]
      h['measurements'] << "#{measurements} (#{dimension_for})"
      h['display_size'] = "(#{measurements})" if k == 'material'
      h['framed'] = framed?(dimension_for) if k == 'mounting' && framed?(dimension_for)
      h[k] = hsh['mounting_ref'][k] if k == 'mounting' && hsh.has_key?('mounting_ref')
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

  #start ####################################################
  def build_dimensions(dimension_params, hsh)
    dimension_params.each do |dimension_field, dimension_val|
      key, dimension_field = dimension_field.split('_')
      assign_or_merge(hsh, key, dimension_field, dimension_val)
    end
  end

  # def extract_dimensions_from_tags(tags, k, hsh)
  #   dimension_params(tags, k).each do |dimension_field, dimension_val|
  #     key, dimension_field = dimension_field.split('_')
  #     assign_or_merge(hsh, key, dimension_field, dimension_val)
  #   end
  # end

  def build_mounting(pg_hsh, k, new_key, fk, hsh)
    if mounting_ref = extract_mounting_ref(pg_hsh, k, fk)
      assign_or_merge(hsh, 'mounting_ref', new_key, mounting_ref)
      assign_or_merge(hsh, 'dimension_for', new_key, dimension_for_val(mounting_ref))
    end
  end

  def extract_mounting_ref(pg_hsh, k, fk)
    if k == 'mounting' && !pg_hsh['field_sets'].has_key?(k)
      wrapped_context(nested_fname(pg_hsh['options'], 'material_id'))
    elsif pg_hsh['field_sets'][k].has_key?('options')
      nested_fname(pg_hsh['field_sets'], k, 'options', fk)
    elsif pg_hsh['field_sets'][k].has_key?(fk)
      nested_fname(pg_hsh['field_sets'], k, fk)
    end
  end
  #end ####################################################
  #
  # def build_mounting_dimension(pg_hsh, store, hsh={'dimensions'=>{}})
  #   %w[mounting dimension].each do |k|
  #     format_mounting_dimensions(pg_hsh, hsh, k, k+'_id')
  #
  #     k, dimensions, dimension_for = attr_dimensions_args(k, hsh)
  #     format_body_dimensions(hsh,k)
  #     attr_dimensions(k, dimensions, dimension_for, store)
  #   end
  #   hsh
  # end

  def format_body_dimensions(hsh, k)
    assign_or_merge(hsh, 'body', k, format_dimensions(hsh['dimensions'][k].select{|k,v| k != 'dimension_for'}))
  end

  def format_mounting_dimensions(pg_hsh, hsh, k, fk)
    extract_dimensions_from_tags(pg_hsh.dig('field_sets', k, 'tags'), hsh, k)
    #add_dimension_for(pg_hsh, hsh, k, fk)
    hsh
  end




  # def extract_dimensions_from_tags(tags, hsh, k)
  #   dimension_params(tags, k).each do |dimension_field, dimension_val|
  #     kind_key, dimension_field = dimension_field.split('_')
  #
  #     assign_or_merge(hsh['dimensions'], kind_key, dimension_field, dimension_val)
  #   end
  #   hsh
  # end

  #kill
  def extract_dimension_for(pg_hsh, k, fk)
    if k == 'mounting' && !pg_hsh['field_sets'].has_key?(k)
      wrapped_context(nested_fname(pg_hsh['options'], 'material_id'))
    elsif pg_hsh['field_sets'][k].has_key?('options')
      nested_fname(pg_hsh['field_sets'], k, 'options', fk)
    elsif pg_hsh['field_sets'][k].has_key?(fk)
      nested_fname(pg_hsh['field_sets'], k, fk)
    end
  end
  #kill
  def attr_dimensions_args(k, hsh)
    k = k == 'dimension' ? 'material' : k
    dimensions = format_attr_dimensions(k, hsh['dimensions'][k]).select{|k,v| k != 'dimension_for'}
    [k, dimensions, hsh['dimensions'].dig(k,'dimension_for')]
  end

  # def attr_dimensions(k, dimensions, dimension_for, store)
  #   store['attrs'].merge!(attr_dimensions_hsh(k, dimensions, dimension_for))
  # end

  #kill
  def add_dimension_for(pg_hsh, hsh, k, fk)
    if val = extract_dimension_for(pg_hsh, k, k+'_id')
      hsh[k] = val
      dimension_for(hsh['dimensions'], k, val) unless included_set?(val, %w[gallery stretched])
    end
  end

  def dimension_for(hsh, k, val)
    #k = k == 'dimension' ? 'material' : k
    hsh[k].merge!({'dimension_for' => dimension_for_val(val)})
  end

  def dimension_for_val(fname)
    case
      when fname.index('fram'); 'frame'
      when fname == 'matted'; 'matting'
      when fname.index('width'); 'image'
      else fname
    end
  end

  def attr_dimensions_hsh(k, dimensions, dimension_for)
    if dimensions.nil? || k=='mounting' && dimension_for != 'frame'
      nil_dimensions(k)
    else
      build_attr_dimensions(dimensions, dimensions.values, attr_dimension_keys(k))
    end
  end

  def nil_dimensions(k)
    attr_dimension_keys(k).map{|i| [i, nil]}.to_h
  end

  def build_attr_dimensions(dimensions, dimension_vals, set)
    return dimensions if dimensions.keys.eql?(set)
    dimension_vals.count == 1 ? set.map{|k| [k, dimension_vals[0]]}.to_h : set.map{|k| [k, dimensions[k]]}.to_h
  end

  # def build_attr_dimensions(dimensions, vals, set)
  #   return dimensions if dimensions.keys == set
  #   vals.count == 1 ? set.map{|k| [k, vals[0]]}.to_h : set.map{|k| [k, dimensions[k]]}.to_h
  # end

  def format_attr_dimensions(k, dimensions)
    k == 'mounting' ? dimensions.transform_keys{|v| 'frame_'+v} : dimensions
  end

  def attr_dimension_keys(k)
    k == 'mounting' ? %w[frame_width frame_height] : %w[width height]
  end

  #########################################

  def dimension_params(tags, k)
    tags ? tags : default_dimension_params(k)
  end

  def default_dimension_params(k)
    keys = k == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end

  def assign_or_merge(h, k,  k2, v)
    if h.has_key?(k)
      h[k].merge!({k2=>v})
    else
      h.merge!({k=>{k2=>v}})
    end
  end

  # mounting_dimension_hsh #####################################################

  def mounting_dimension_hsh(pg_hsh, store, hsh={'dimension'=>{}})
    mounting_hsh(pg_hsh, store)
    dimension_hsh(pg_hsh['field_sets'], store, hsh)
  end

  # refactored mounting_hsh ##############################################################
  def mounting_hsh(pg_hsh, store, k='mounting')
    if mounting = mounting_value_case(pg_hsh, k, k+'_id')
      detail_mounting(k, mounting, store)
    end
  end

  def mounting_value_case(pg_hsh, k, fk)
    if wrapped_mounting = wrapped_mounting(nested_fname(pg_hsh['options'], 'material_id')) #gallery wrapped, stretched
      wrapped_mounting
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

  def wrapped_mounting(material)
    wrapped_mounting_value(material) if material
  end

  def wrapped_mounting_value(material)
    if material.split(' ').include?('gallery')
      'gallery wrapped'
    elsif material.split(' ').include?('stretched')
      'stretched'
    end
  end

  def fs_opt_mounting(mounting)
    framed(mounting) if mounting
  end

  # def framed(mounting)
  #   mounting if mounting.split(' ').include?('framed')
  # end

  def fs_mounting(mounting)
    fs_mounting_value(mounting) if mounting
  end

  def fs_mounting_value(mounting)
    mounting == 'matting' ? 'matted' : mounting
  end

  def fs_dimension(mounting)
    fs_dimension_value(mounting) if mounting
  end

  def fs_dimension_value(mounting)
    mounting == 'width & height' ? 'image' : mounting
  end

  def nested_fname(pg_hsh, *keys)
    pg_hsh.dig(*keys).try(:field_name)
  end

  # dimension_hsh: kill ##############################################################
  def dimension_hsh(fs_hsh, store, hsh)
    export_dimensions(build_dimension_hsh(fs_hsh, hsh['dimension']), store)
    update_fs_hsh(fs_hsh)
  end
  # kill
  def build_dimension_hsh(fs_hsh, d_hsh)
    %w[mounting dimension].each do |kind|
      tags, obj = ['tags', kind+'_id'].map{|key| fs_hsh.dig(kind, key)}
      build_nested_dimension_hsh(dimension_tags(tags, kind), obj.try(:field_name), d_hsh)
    end
    d_hsh
  end
  # kill
  def build_nested_dimension_hsh(dimension_tags, fname, d_hsh)
    dimension_tags.each do |d_key, d_val|
      k, k2 = d_key.split('_')
      d_hsh[k] = {'dimension_type'=> dimension_type(fname)} if !d_hsh.has_key?(k)
      assign_or_merge(d_hsh[k], 'dimensions',  k2, d_val)
    end
    d_hsh
  end
  # kill
  def export_dimensions(d_hsh, store, hsh={}, tag_set=[])
    d_hsh.each do |d_kind, d_kind_hsh|
      dimensions, dimension_type = d_kind_hsh['dimensions'], d_kind_hsh['dimension_type']
      hsh.merge!(attr_dimensions(d_kind, dimensions, dimension_type))

      tag_set << format_dimensions(dimensions) + ' ' + "(#{dimension_type})" if dimensions.values.none?{|v| v.blank?}
    end
    hsh.each {|k,v| store['attrs'].merge!({k=>v})}
    detail_dimension(store, 'dimension', tag_set)
  end
  # kill
  def dimension_tags(tags, kind)
    tags ? tags : default_tags(kind)
  end
  # kill
  def default_tags(kind)
    keys = kind == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end
  # kill
  def dimension_type(fname)
    case fname
      when 'framing'; 'frame'
      when 'matted'; 'matting'
      when 'width & height'; 'image'
      else fname
    end
  end
  # kill
  def attr_material_dimension(tags)
    return tags if tags.keys == %w[width height]
    tag_vals = tags.values
    tag_vals.count == 1 ? %w[width height].map{|k| [k, tag_vals[0]]}.to_h : %w[width height].each_with_index{|(k,v), idx| [k, tag_vals[idx]]}.to_h
  end
  # kill
  def attr_mounting_dimension(dimension_type, tags)
    dimension_type == 'frame' ? tags : tags.transform_values!{|v| nil}
  end
  #num_str.gsub(/\D/, '')
  # def format_dimensions(dimensions)
  #   #dimensions.values.reject{|i| i.blank?}.map{|i| i+"\""}.join(' x ')
  #   dimensions.values.map{|i| i+"\""}.join(' x ') #dimensions.values.any?{|i| i.nil?}
  # end

  # def format_dimensions(dimension_values)
  #   #dimensions.values.reject{|i| i.blank?}.map{|i| i+"\""}.join(' x ')
  #   dimension_values.map{|i| i+"\""}.join(' x ') #dimensions.values.any?{|i| i.nil?}
  # end

  def format_dimensions(dimension_vals)
    dimension_vals.map{|i| i+"\""}.join(' x ')
  end

  def update_fs_hsh(fs_hsh)
    fs_hsh.delete('dimension')
    fs_hsh.delete('mounting')
  end

  # product_hsh ################################################################## {"media"=>{"category"=>"Original", "medium"=>"watercolor painting", "material"=>"paper"}}
  def product_hsh(product, options, hsh={'product'=>{}})
    build_product_hsh(product).each do |kind, media|
      hsh['product'].merge!({kind => build_product_media(kind, media, options)})
    end
    hsh['product']
  end

  def export_product_media(product_hsh, store)
    product_hsh.each do |k, media|
      store['attrs'].merge!(attr_product_media_case(k, media))
    end
  end

  def build_options(opt_hsh, h={'opt_hsh'=>{}})
    opt_hsh.reject{|fk,obj| obj.nil?}.each do |fk, obj|
      h['opt_hsh'].merge!({obj.kind=>obj.field_name})
    end
    h['opt_hsh']
  end

  def build_product_media_hsh(product, options, store, hsh)
    build_product_hsh(product).each do |kind, media|
      hsh['product'].merge!({kind => build_product_media(kind, media, options)})
    end
    hsh['product']
  end

  def build_product_hsh(product)
    product_keys.map{|k| [k, product.tags[k]]}.to_h.reject{|k,v| v == 'n/a'}
  end

  def build_product_media(kind, media, options)
    kind == 'medium' && options.has_key?(kind) ? attr_product_medium_case(options[kind]) : media
  end

  def attr_product_medium_case(medium)
    case
      when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(medium); medium
      when medium == 'Silkscreen'; 'Serigraph'
      when medium.underscore.split('_').include?('painting'); 'Painting'
      when medium.underscore.split('_').include?('drawing'); 'Drawing'
      else 'Mixed Media'
    end
  end

  def default_attr_media
    attr_product_keys.map{|k| [k, nil]}.to_h
  end

  # opt_media_hsh ##########################################################
  def opt_media_hsh(options, product_media, store)
    opt_media_keys(product_media.keys, options.keys).each do |kind|
      description_hsh(store, kind, media_value(options, product_media, kind))
    end
  end

  def media_value(options, product_media, k)
    if options.has_key?(k) && options[k]
      options[k]
    elsif product_media.has_key?(k)
      product_media[k].underscore.split('_').join(' ')
    end
  end

  def tagline_material_value(material)
    ['wrapped canvas', 'stretched canvas'].any?{|k| k == material} ? 'Canvas' : material.split(' ').map{|k| k.capitalize}.join(' ')
  end

  def body_material_value(material)
    material.split(' ').include?('wrapped') ? 'canvas' : material
  end

  def opt_media_keys(p_keys, m_keys)
    product_keys.prepend('embellished').select{|k| p_keys.include?(k) || m_keys.include?(k)}
  end

  # fs_media_hsh ############################################################### => {"mounting"=>{"field_name"=>"framed"}, "signature"=>{"field_name"=>"hand signed"}, "certificate"=>{"field_name"=>"LOA"}}
  def fs_opt_media(fs_hsh, store)
    build_fs_opt_hsh(fs_hsh).each do |kind, kind_val|
      description_hsh(store, kind, kind_val)
      fs_hsh.delete(kind)
    end
  end

  def build_fs_opt_hsh(fs_hsh, hsh={})
    fs_hsh.each do |k, kind_param|
      if kind_param.has_key?('options') && kind_param['options'][k+'_id'] && kind_param.keys.count == 1
        hsh.merge!({k => kind_param['options'][k+'_id'].field_name})
      end
    end
    hsh
  end

  # def search_tagline_mounting(k, mounting)
  #   if mounting.split(' ').include?('framed')
  #     {k => mounting}
  #   else
  #     {k => "(#{mounting})"}
  #   end
  # end

  def tagline_signature(v)
    if v.split(' ').include?('authorized')
      'signed'
    elsif v == 'unsigned'
      '(Unsigned)'
    else
      v
    end
  end

  def body_signature(v)
    if k = %w[plate authorized].detect{|k| v.split(' ').include?(k)}
      "bearing the #{k} signature of the artist."
    elsif v.split(' ').include?('estate')
      "#{v}."
    elsif v == 'unsigned'
      'This piece is unsigned.'
    else
      "#{v} by the artist."
    end
  end

  def numbering_value(numbering, opt_numbering, tags)
    if numbering == 'proof edition' || tags && tags.values.any?{|i| i.blank?}
      opt_numbering
    elsif tags
      "#{opt_numbering} #{tags.values.join('/')}"
    end
  end

  # format_description ################################################################
  def format_description(store)
    description_keys_hsh(store).each do |context, media_keys|
      store['attrs'][context] = build_description(context, store[context], media_keys)
    end
     store['attrs'].merge!({'property_room' => property_room(store['attrs']['tagline'], 128)})
     store['attrs']
  end

  def property_room(build, i)
    sub_list.each do |sub_arr|
      return build.squish if build.squish.size <= i
      build = build.gsub(sub_arr[0], sub_arr[-1]).squish
    end
    build
  end

  def sub_list
    [
      ["Certificate of Authenticity", "COA"],
      ["Letter of Authenticity", "LOA"],
      [" with ", " w/"], [" and ", " & "], [" Numbered ", " No "],
      ["Hand Embellished", ""], ["Artist Embellished", ""],
      ["Gold Leaf", "GoldLeaf"], ["Silver Leaf", "SilverLeaf"],
      ["Hand Drawn Remarque", ""]
    ]
  end

  def build_description(context, media_hsh, media_keys, set=[])
    media_keys.each do |media_key|
      media_val = assign_media(context, media_hsh, media_keys, media_key, media_hsh[media_key])
      set << tagline_cap(context, media_val, media_key)
    end
    set.join(' ')
  end

  def assign_media(context, media_hsh, media_keys, media_key, media_val)
    if updated_media = format_description_case(context, media_hsh, media_keys, media_key, media_val)
      updated_media
    else
      media_val
    end
  end

  def format_description_case(context, media_hsh, media_keys, media_key, media_val)
    case media_key
      when 'title'; format_title(context, media_val, media_hsh[media_keys[1]])
      when 'medium'; format_medium(context, media_keys, media_val)
      when 'material'; format_material(context, media_keys, media_val)
      when 'leafing'; format_leafing(media_keys, media_val)
      when 'remarque'; format_remarque(context, media_keys, media_val)
      when 'numbering'; format_numbering(media_keys, media_val, media_val.split(' ').include?('from'))
    end
  end

  def format_title(context, media_val, next_media)
    #context == 'tagline' ? media_val :  "#{media_val} is #{format_vowel(next_media, ['one-of-a-kind', 'unique'])}"
    %w[tagline search_tagline].include?(context) ? media_val :  "#{media_val} is #{format_vowel(next_media, ['one-of-a-kind', 'unique'])}"
  end

  def format_medium(context, media_keys, media_val)
    #return unless context == 'tagline'
    return unless %w[tagline search_tagline].include?(context)
    %w[leafing remarque].all? {|k| media_keys.exclude?(k)} ? media_val : "#{media_val},"
  end

  def format_material(context, media_keys, media_val)
    #return unless context == 'tagline' && %w[leafing remarque].all? {|i| media_keys.exclude?(i)}
    return unless %w[tagline search_tagline].include?(context) && %w[leafing remarque].all? {|i| media_keys.exclude?(i)}
    "#{media_val},"
  end

  def format_leafing(media_keys, media_val)
    punct = ',' if media_keys.exclude?('remarque')
    "with #{[media_val, punct].join('')}"
  end

  def format_remarque(context, media_keys, media_val)
    word = media_keys.include?('leafing') ? 'and' : 'with'
    "#{word} #{media_val},"
  end

  def format_numbering(media_keys, media_val, proof_bool)
    if proof_bool && %w[leafing remarque].all? {|k| media_keys.exclude?(k)} #proof_context + context
      "#{media_val},"
    elsif !proof_bool && media_keys.include?('signature')
      "#{media_val} and"
    end
  end

  ##############################################################################

  def description_keys_hsh(store, hsh={})
    tagline_key_hsh(store['tagline'], hsh)
    search_tagline_key_hsh(store['search_tagline'].keys, hsh)
    body_key_hsh(store['body'], hsh)
    hsh
  end

  def tagline_key_hsh(tagline, hsh, k='tagline')
    hsh.merge!({k => tagline_keys(tagline, tagline.keys)})
  end

  def search_tagline_key_hsh(tagline_keys, hsh, k='search_tagline')
    hsh.merge!({k => tagline_keys.reject{|k,v| k == 'artist_name'}})
  end

  def body_key_hsh(body, hsh, k='body')
    hsh.merge!({k=> all_body_keys.select{|k| body.has_key?(k)}})
  end
  ##############################################################################
  # def description_keys_hsh(store)
  #   {'tagline' => tagline_keys(store['tagline'], store['tagline'].keys), 'body' => all_body_keys.select{|k| store['body'].has_key?(k)}}
  # end

  def tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = sorted_tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = tagline_keys.reject {|k| reject_tagline_keys(tagline_hsh, k, tagline_hsh[k])}
  end

  def sorted_tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = all_tagline_keys.select{|k| tagline_keys.include?(k)}
    reorder_numbering_key(tagline_hsh, tagline_keys)
  end

  def search_tagline_keys(search_tagline_hsh, search_tagline_keys)
    sorted_search_tagline_keys(search_tagline_hsh, search_tagline_keys)
  end

  def sorted_search_tagline_keys(search_tagline_hsh, search_tagline_keys)
    search_tagline_keys = all_search_tagline_keys.select{|k| search_tagline_keys.include?(k)}
    reorder_numbering_key(search_tagline_hsh, search_tagline_keys)
    #reorder_mounting_key(search_tagline_hsh, search_tagline_keys)
  end

  def reorder_numbering_key(tagline_hsh, tagline_keys, k='numbering')
    return tagline_keys unless tagline_hsh[k] && tagline_hsh[k].split(' ')[0] == 'from'
    tagline_keys.delete(k)
    tagline_keys.insert(tagline_keys.index('material'), k)
    tagline_keys
  end

  # def reorder_mounting_key(search_tagline_hsh, search_tagline_keys, k='mounting')
  #   return search_tagline_keys unless search_tagline_hsh[k] && search_tagline_hsh[k].split(' ').include?('framed')
  #   search_tagline_keys.delete(k)
  #   search_tagline_keys.insert(0, k)
  #   search_tagline_keys
  # end

  def reject_tagline_keys(tagline_hsh, k, v)
    case k
      when 'medium' && v.downcase.split(' ').include?('giclee') && tagline_hsh['material'].downcase.split(' ').exclude?('paper'); true
      when 'material' && v.split(' ').include?('paper'); true
      else false
    end
  end

  def all_tagline_keys
    %w[artist_name title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate]
  end

  def all_search_tagline_keys
    %w[embellished category sub_category medium material leafing remarque numbering signature certificate mounting]
  end

  def all_body_keys
    %w[title embellished category sub_category medium material leafing remarque artist_name numbering signature mounting certificate dimension]
  end

  # END OF REVAMPED export_params METHODS  #####################################
  ##############################################################################

  # def body_keys(d_store, d_keys)
  #   all_body_keys.select{|k| d_keys.include?(k)}
  # end

  ##############################################################################

  def csv_attr_and_val(obj, obj_name)
    csv_target_keys(obj_name).map{|k| [k, get_attr_val(obj, k)]}.to_h
  end

  def get_attr_val(obj, attr)
    obj.nil? ? nil : obj.public_send(attr)
  end

  def nested_hsh(k:, k2: 'field_name', v: nil)
    {k=>{k2=>v}}
  end

  # def assign_or_merge(h, k,  k2, v)
  #   if h.has_key?(k)
  #     h[k].merge!({k2=>v})
  #   else
  #     h.merge!(nested_hsh(k: k, k2: k2, v: v))
  #   end
  # end
  def included_set?(str, set)
    str.split(' ').any?{|i| set.include?(i)}
  end

  def format_vowel(word, exception_set=[])
    %w[a e i o u].include?(word.first.downcase) && exception_set.exclude?(word) ? 'an' : 'a'
  end

  def tagline_cap(context, media_val, media_key)
    if %w[tagline search_tagline].include?(context) && %[artist_name title dimension].exclude?(media_key)
      cap_words(media_val.split(' '))
    else
      media_val
    end
  end

  def cap_words(word_set, set=[])
    word_set.each do |word|
      set << cap_case(word)
    end
    set.join(' ')
  end

  def cap_case(word)
    if acronym?(word) || excluded_word?(word)
      word
    else
      word.capitalize
    end
  end

  def acronym?(word)
    ('A'..'Z').include?(word[0])
  end

  def excluded_word?(word)
    %w[a an on of and from with].include?(word)
  end

  def decamelize(name)
    name.underscore.split('_').join(' ')
  end

  # update THIS ################################################################
  def attr_product_keys
    %w[media dimension description].map{|k| csv_target_key_set(k)}.flatten(1).sort {|a,b| a[0] <=> b[0]}.map{|set| set[1]}
  end

  def csv_target_keys(target)
    csv_target_key_set(target).map{|set| set[1]}
  end

  def csv_target_key_set(target)
    public_send(['csv', target, 'keys'].join('_'))
  end

  def get_key_set(key_sets)
    key_sets.map{|set| set[1]}
  end

  def csv_item_keys
    [[0, 'sku'], [3, 'title'], [7, 'retail'], [8, 'qty']]
  end

  def csv_artist_keys
    [[1, 'artist_name'], [2, 'artist_id']]
  end

  def csv_dimension_keys
    [[12, 'width'], [13, 'height'], [14, 'frame_width'], [15, 'frame_height']]
  end

  def csv_media_keys
    [[9, 'art_type'], [10, 'art_category'], [11, 'medium'], [12, 'material']]
  end

  def csv_description_keys
    [[4, 'tag_line'], [5, 'property_room'], [6, 'description']]
  end
end



  # mounting_hsh ###############################################################
  # def mounting_hsh(pg_hsh, store, k='mounting')
  #   if mounting = mounting_value_case(pg_hsh, k)
  #     detail_mounting(k, mounting, store)
  #   end
  # end
  #
  # def mounting_value_case(pg_hsh, k)
  #   if mounting = wrapped_mounting_value(pg_hsh.dig('options', 'material_id').try(:field_name))
  #     mounting
  #   elsif mounting = pg_hsh.dig('field_sets', k, 'options', k+'_id').try(:field_name)
  #     #puts "mounting: #{mounting}"
  #     mounting == 'matting' ? 'matted' : mounting
  #   end
  # end
  #
  # def wrapped_mounting_value(material)
  #   'gallery wrapped' if material && material.split(' ').include?('gallery')
  # end
