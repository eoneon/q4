class Export

  ####################### h = Export.new.csv_test(6)  <!--> Item.find(6).csv_tags product_group['params']['field_sets']  h = Item.find(5).product_group['params']['options']

  def csv_test(i, store=to_hsh(%w[attrs tagline search_tagline body]))
    pg_hsh = Item.find(i).product_group['params']
    mounting_dimension(pg_hsh, store)
    store
  end

  # EXPORT: ITEM & PARAMS: PRODUCT, OPTIONS & FIELD-SET ########################
  def export_params(item, product, artist, pg_hsh, store=to_hsh(%w[attrs tagline search_tagline body]))
    csv_values_from_item(item, artist, store)
    csv_values_from_params(product, pg_hsh, store)
  end

  def csv_values_from_item(item, artist, store, hsh={'item'=>{}})
    build_item_params(item, artist, store, hsh['item'])
  end

  def csv_values_from_params(product, pg_hsh, store)
    return store['attrs'].merge!(attr_default_media) if product.nil?
    csv_values_from_product_and_options(product, build_options(pg_hsh['options']), store)
    csv_values_from_field_sets(pg_hsh, store)
    format_description(store)
  end

  # ITEM VALUES ################################################################
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

  # PRODUCT & OPTIONS MEDIA VALUES #############################################
  def csv_values_from_product_and_options(product, options, store)
    product_hsh = product_hsh(product, options)
    export_product_media(product_hsh, store)
    opt_media_hsh(options, product_hsh, store)
  end

  def build_options(opt_hsh, h={'opt_hsh'=>{}})
    opt_hsh.reject{|fk,obj| obj.nil?}.each do |fk, obj|
      h['opt_hsh'].merge!({obj.kind=>obj.field_name})
    end
    h['opt_hsh']
  end

  def csv_values_from_field_sets(pg_hsh, store)
    mounting_dimension(pg_hsh, store)
    fs_opt_media(pg_hsh['field_sets'], store)
    detail_numbering(pg_hsh['field_sets'], 'numbering', store)
  end

  ## PRODUCT MEDIA VALUES  ######################################################
  # csv_values_from_product_and_options methods ################################ {"media"=>{"category"=>"Original", "medium"=>"watercolor painting", "material"=>"paper"}} # product_hsh ################################################################ => {"product"=>{"category"=>"Original", "medium"=>"Painting", "material"=>"Board"}}
  def product_hsh(product, options, hsh={'product'=>{}})
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

  def export_product_media(product_hsh, store)
    product_hsh.each do |k, media|
      store['attrs'].merge!(attr_product_media_case(k, media))
    end
  end

  ## OPTION MEDIA  #############################################################
  def opt_media_hsh(options, product_media, store)
    opt_media_keys(product_media.keys, options.keys).each do |kind|
      description_hsh(store, kind, media_value(options, product_media, kind))
    end
  end

  ## FIELD-SET MEDIA VALUES I ##################################################
  ### MOUNTING & DIMENSION: build, attr & detail  ############################## => {"dimensions"=>{"mounting"=>{"width"=>nil, "height"=>nil}, "material"=>{"width"=>"25", "height"=>"25"}}, "mounting"=>{"search_tagline"=>"gallery wrapped", "body"=>"gallery wrapped"}, "material"=>{"measurements"=>"25\" x 25\"", "dimension_for"=>"image"}}
  def mounting_dimension(pg_hsh, store)
    hsh = build_detail_dimension(build_mounting_dimension(pg_hsh))
    attr_dimensions(hsh['dimensions'], hsh.dig('dimension_for', 'mounting'), store)
    detail_mounting_dimension(hsh, store)
    update_fs_hsh(pg_hsh['field_sets'])
  end

  #### BUILD
  def build_detail_dimension(hsh, h={'tagline'=>{}, 'search_tagline'=>{}, 'body'=>[]})
    %w[mounting material].each do |k|
      measurements, dimension_for = %w[measurements dimension_for].map{|key| hsh.dig(k, key)}
      next if measurements.nil?
      detail_dimension_hsh(measurements, hsh.dig('dimensions', k), dimension_for, k, h)
    end
    update_dimension(h, hsh)
  end

  def build_mounting_dimension(pg_hsh, hsh=to_hsh(%w[dimensions mounting material]))
    %w[mounting dimension].each do |k|
      new_key, dimension_params = k == 'dimension' ? 'material' : k, dimension_params(pg_hsh.dig('field_sets', k, 'tags'), k)
      build_dimensions(dimension_params, hsh['dimensions'])
      build_measurements(hsh['dimensions'][new_key], hsh, new_key)
      build_mounting(pg_hsh, new_key, k, k+'_id', hsh)
    end
    hsh
  end

  ##### DIMENSION-SPECIFIC
  def detail_dimension_hsh(measurements, dimensions, dimension_for, k, h)
    description_keys.each do |dkey|
      if dkey == 'search_tagline' || dkey == 'tagline' && oversized_values?(dimensions.values, dimension_for, k)
        h[dkey] = "(#{measurements})"
      elsif dkey == 'body'
        h[dkey] << "#{measurements} (#{dimension_for})"
      end
    end
  end

  def build_dimensions(dimension_params, hsh)
    dimension_params.each do |dimension_field, dimension_val|
      new_key, dimension_field = dimension_field.split('_')
      assign_or_merge(hsh, new_key, dimension_field, dimension_val)
    end
  end

  def build_measurements(dimensions, hsh, k)
    if dimensions && dimensions.values.none?{|i| i.nil?}
      assign_or_merge(hsh, k, 'measurements', build_measurement(dimensions.values))
    end
    hsh
  end

  def build_measurement(dimension_vals)
    dimension_vals.map{|i| i+"\""}.join(' x ')
  end

  def oversized_values?(dimension_vals, dimension_for, k)
    dimension_vals.all?{|i| i.to_i >= 40} && oversized_scope?(dimension_for, k)
  end

  def oversized_scope?(dimension_for, k)
    k == 'mounting' &&  %w[frame matting].include?(dimension_for) || k == 'material' && dimension_for != 'frame'
  end

  ##### MOUNTING-SPECIFIC
  def build_mounting(pg_hsh, new_key, k, fk, hsh)
    build_mounting_hsh(pg_hsh, new_key, k, fk, hsh)
    if mounting = hsh.dig('mounting', 'body')
      hsh['mounting']['body'] = "This piece comes #{mounting}." if patt_exist?(%w[fram matt gallery], mounting)
    end
  end

  def build_mounting_hsh(pg_hsh, new_key, k, fk, hsh)
    if mounting = wrapped?(nested_fname(pg_hsh['options'], new_key+'_id'))
      wrapped_mounting(mounting, hsh)
    elsif mounting = image_value?(nested_fname(pg_hsh['field_sets'], k, fk))
      image_value(mounting, hsh)
    elsif mounting = framed?(nested_fname(pg_hsh['field_sets'], k, 'options', fk))
      framed_mounting(mounting, hsh)
    elsif mounting = other_mounting?(nested_fname(pg_hsh['field_sets'], k, fk))
      other_mounting(mounting, hsh)
    end
  end

  def wrapped?(fname)
    detect_and_sub(fname, [['gallery','gallery wrapped'], ['stretched']])
  end

  def wrapped_mounting(mounting, hsh)
    assign_or_merge(hsh, 'material', 'dimension_for', 'image')
    assign_or_merge(hsh, 'mounting', 'search_tagline', mounting)
    assign_or_merge(hsh, 'mounting', 'body', mounting) if mounting != 'stretched'
  end

  def image_value?(fname)
    detect_and_sub(fname, [['width', 'image'], ['image-diameter']])
  end

  def image_value(mounting, hsh)
    assign_or_merge(hsh, 'material', 'dimension_for', mounting)
    assign_or_merge(hsh, 'mounting', 'search_tagline', mounting)
  end

  def framed?(fname)
    detect_and_sub(fname, [['framed', fname]])
  end

  def framed_mounting(mounting, hsh)
    assign_or_merge(hsh, 'mounting', 'dimension_for', 'frame')
    assign_or_merge(hsh, 'mounting', 'tagline', 'framed')
    assign_or_merge(hsh, 'mounting', 'search_tagline', mounting)
    assign_or_merge(hsh, 'mounting', 'body', mounting)
  end

  def other_mounting?(fname)
    detect_and_sub(fname, [['matting'], ['border']])
  end

  def other_mounting(mounting, hsh)
    assign_or_merge(hsh, 'mounting', 'dimension_for', mounting)
    assign_or_merge(hsh, 'mounting', 'search_tagline', mounting)
    assign_or_merge(hsh, 'mounting', 'body', 'matted') if patt_exist?(%w['matt'], mounting)
  end

  def update_dimension(h, hsh)
    return if h.empty?
    h['body'] = "Measures approx. #{h['body'].join(', ')}." unless h['body'].empty?
    hsh.merge!({'dimension'=>h})
  end

  #### DETAIL: MOUNTING & DIMENSION
  def detail_mounting_dimension(hsh, store)
    %w[mounting dimension].each do |key|
      compact_hsh(hsh)
      description_keys.map{|k| assign_or_merge(store, k, key, hsh.dig(key, k)) if hsh.dig(key, k)}
    end
  end

  # def assign_store_values(set, hsh, store)
  #   set.each do |key|
  #     compact_hsh(hsh)
  #     description_keys.map{|k| assign_or_merge(store, k, key, hsh.dig(key, k)) if hsh.dig(key, k)}
  #   end
  # end

  #### ATTRS: DIMENSIONS
  def attr_dimensions(hsh, mounting, store)
    hsh.each do |k, dimensions|
      dimensions = format_attr_dimensions(k, mounting, dimensions)
      store['attrs'].merge!(build_attr_dimensions(dimensions, dimensions.values.take(2), attr_dimension_keys(k)))
    end
  end

  def format_attr_dimensions(k, mounting, dimensions)
    dimensions.transform_keys{|v| 'frame_'+v} if k == 'mounting'
    dimensions.transform_values{|v| nil} if mounting == 'frame'
    dimensions
  end

  def build_attr_dimensions(dimensions, dimension_vals, set)
    return dimensions if dimensions.keys.eql?(set)
    dimension_vals.count == 1 ? set.map{|k| [k, dimension_vals[0]]}.to_h : set.map{|k| [k, dimensions[k]]}.to_h
  end

  def attr_dimension_keys(k)
    k == 'mounting' ? %w[frame_width frame_height] : %w[width height]
  end

  ###### UTILTIY METHODS
  def dimension_params(tags, k)
    tags ? tags : default_dimension_params(k)
  end

  def default_dimension_params(k)
    keys = k == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end

  def update_fs_hsh(fs_hsh)
    fs_hsh.delete('dimension')
    fs_hsh.delete('mounting')
  end
  # END FIELD-SET MEDIA VALUES I: MOUNTING & DIMENSION #########################

  # FIELD-SET MEDIA VALUES II: #################################################
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

  ## ATTR METHODS: PRODUCT-MEDIA ###############################################
  def attr_product_medium_case(medium)
    case
      when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(medium); medium
      when medium == 'Silkscreen'; 'Serigraph'
      when medium.underscore.split('_').include?('painting'); 'Painting'
      when medium.underscore.split('_').include?('drawing'); 'Drawing'
      else 'Mixed Media'
    end
  end

  def attr_default_media
    attr_product_keys.map{|k| [k, nil]}.to_h
  end

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

  ## DETAIL: PRODUCT-MEDIA #####################################################
  def description_hsh(store,k,v)
    return if v.blank?
    description_case(store,k,v)
  end

  def description_case(store,k,v)
    case
      when k == 'title'; detail_title(store,k,v)
      when k == 'artist_name'; detail_artist(store,k,v)
      when k == 'category' && v == 'one of a kind'; detail_category(store,k)
      when k == 'material'; detail_material(store,k,v)
      when k == 'signature'; detail_signature(store,k,v)
      when k == 'certificate'; detail_certificate(store,k,v)
      else default_detail(store,k,v)
    end
  end

  def detail_title(store,k,v)
    title = v == 'Untitled' ? 'This' : "\"#{v}\""
    store['tagline'].merge!({k=>title}) if title != 'This'
    store['body'].merge!({k=>title})
  end

  def detail_artist(store,k,v)
    store['tagline'].merge!({k=> "#{v},"})
    store['body'].merge!({k=> "by #{v},"})
  end

  def detail_category(store, k, v='One-of-a-Kind')
    map_merge(description_keys.take(2), k, v, store)
    store['body'].merge!({k=>'one-of-a-kind'})
  end

  def detail_material(store,k,v)
    return if v == 'Sericel'
    store['tagline'].merge!({k => "on #{tagline_material_value(v)}"}) if store['attrs']['material'] != 'Paper'
    store['search_tagline'].merge!({k => "on #{v}"})
    store['body'].merge!({k => "on #{body_material_value(v)}"})
  end

  def detail_signature(store, k, v)
    map_merge(description_keys.take(2), k, tagline_signature(v), store)
    store['body'].merge!({k=>body_signature(v)})
  end

  def detail_certificate(store, k, v)
    store['search_tagline'].merge!({k =>"with #{v}"})
    v = v == 'LOA' ? 'Letter' : 'Certificate'
    store['tagline'].merge!({k=> "with #{v} of Authenticity."})
    store['body'].merge!({k=> "Includes #{v} of Authenticity."})
  end

  def detail_numbering(fs_hsh, k, store)
    fs_numbering, opt_numbering, numbering_params = nested_fname(fs_hsh, k, k+'_id'), nested_fname(fs_hsh, k, 'options', k+'_id'), format_numbering_params(fs_hsh.dig(k, 'tags'))
    return if !fs_numbering || !opt_numbering
    #numbering_value = numbering_value(fs_numbering, opt_numbering, numbering_params)
    numbering_value = [opt_numbering, numbering_params].compact.join(' ')
    map_merge(description_keys, k, numbering_value, store)
    # store['tagline'].merge!({k=> numbering_value})
    # store['search_tagline'].merge!({k => opt_numbering}) #abbrv later?
    # store['body'].merge!({k=> numbering_value})
  end

  def format_numbering_params(tags)
    tags.values.join('/') if tags && tags.values.none?{|i| i.blank?}
  end

  def default_detail(store,k,v)
    store['tagline'].merge!({k=>v.split(' ').map{|k| k.capitalize}.join(' ')})
    store['search_tagline'].merge!({k=>v})
    store['body'].merge!({k=>v})
  end

  # nested detail methods:
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

  def numbering_value(fs_numbering, opt_numbering, numbering_params)
    #puts "special_edition: #{opt_numbering}"
    if fs_numbering == 'proof edition' || !numbering_params
      opt_numbering
    elsif numbering_params
      "#{opt_numbering} #{numbering_params}"
    end
  end

  # def numbering_value(fs_numbering, opt_numbering, tags)
  #   #puts "special_edition: #{opt_numbering}"
  #   if fs_numbering == 'proof edition' || tags && tags.values.any?{|i| i.blank?}
  #     opt_numbering
  #   elsif tags
  #     "#{opt_numbering} #{tags.values.join('/')}"
  #   end
  # end
  # end

  # FORMAT DESCRIPTION #########################################################
  def format_description(store)
    description_keys.each do |context|
      media_keys = scoped_media_keys(context, store)
      store['attrs'][context] = build_description(context, store[context], update_keys(context, media_keys, store[context]))
    end
    store['attrs'].merge!({'property_room' => property_room(store['attrs']['tagline'], 128)})
    store['attrs']
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

  def scoped_media_keys(context, store)
    store[context].delete_if{|k,v| v.blank?}
    ordered_keys[context].select{|k| store[context].has_key?(k)}
  end

  def update_keys(context, media_keys, context_hsh)
    if context == 'tagline'
      update_tagline_keys(context_hsh, media_keys)
    else context == 'search_tagline'
      reorder_numbering_key(context_hsh, media_keys)
    end
  end

  def update_tagline_keys(context_hsh, media_keys)
    reorder_numbering_key(context_hsh, media_keys)
    media_keys.reject {|k| reject_tagline_keys(context_hsh, k, context_hsh[k])}
  end

  def reorder_numbering_key(context_hsh, media_keys, k='numbering')
    return media_keys unless context_hsh[k] && context_hsh[k].split(' ')[0] == 'from'
    media_keys.delete(k)
    target = %w[material medium category].detect{|key| media_keys.include?(key)}
    media_keys.insert(media_keys.index(target)+1, k)
  end
  # end ########################################################################

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

  # FORMAT DESCRIPTION #########################################################

  def format_description_case(context, media_hsh, media_keys, media_key, media_val)
    case media_key
      when 'title'; format_title(context, media_val, media_hsh[media_keys[1]])
      when 'medium'; format_medium(context, media_keys, media_val)
      when 'material'; format_material(context, media_keys, media_val)
      when 'leafing'; format_leafing(context, media_keys, media_val)
      when 'remarque'; format_remarque(context, media_keys, media_val)
      when 'numbering'; format_numbering(media_keys, media_val, media_val.split(' ').include?('from'))
    end
  end

  def format_title(context, media_val, next_media)
    %w[tagline search_tagline].include?(context) ? media_val :  "#{media_val} is #{format_vowel(next_media, ['one-of-a-kind', 'unique'])}"
  end

  def format_medium(context, media_keys, media_val)
    return unless %w[tagline search_tagline].include?(context)
    %w[material leafing remarque].any? {|k| media_keys.include?(k)} ? media_val : "#{media_val},"
  end

  def format_material(context, media_keys, media_val)
    return unless %w[tagline search_tagline].include?(context) && %w[leafing remarque].all? {|i| media_keys.exclude?(i)}
    "#{media_val},"
  end

  def format_leafing(context, media_keys, media_val)
    punct = ',' if context != 'body' && media_keys.exclude?('remarque')
    "with #{[media_val, punct].join('')}"
  end

  def format_remarque(context, media_keys, media_val)
    word = media_keys.include?('leafing') ? 'and' : 'with'
    media_val = context != 'body' ? media_val+',' : media_val
    "#{word} #{media_val}"
  end

  def format_numbering(media_keys, media_val, proof_bool)
    if proof_bool && %w[leafing remarque].all? {|k| media_keys.exclude?(k)}
      "#{media_val},"
    elsif !proof_bool && media_keys.include?('signature')
      "#{media_val} and"
    end
  end

  ##############################################################################

  def reject_tagline_keys(tagline_hsh, k, v)
    case k
      when 'medium' && v.downcase.split(' ').include?('giclee') && tagline_hsh['material'].downcase.split(' ').exclude?('paper'); true
      when 'material' && v.split(' ').include?('paper'); true
      else false
    end
  end

  def ordered_keys
    {
      'tagline'=> %w[artist_name title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate],
      'search_tagline'=> %w[embellished category sub_category medium material leafing remarque numbering signature certificate mounting dimension],
      'body'=> %w[title embellished category sub_category medium material leafing remarque artist_name numbering signature mounting certificate dimension]
    }
  end

  def product_keys
    %w[category sub_category medium material]
  end

  def description_keys
    %w[tagline search_tagline body]
  end

  def opt_media_keys(p_keys, m_keys)
    product_keys.prepend('embellished').select{|k| p_keys.include?(k) || m_keys.include?(k)}
  end
  ##############################################################################

  def csv_attr_and_val(obj, obj_name)
    csv_target_keys(obj_name).map{|k| [k, get_attr_val(obj, k)]}.to_h
  end

  def get_attr_val(obj, attr)
    obj.nil? ? nil : obj.public_send(attr)
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

  # utility methods: ###########################################################
  # hash methods: ##############################################################
  def nested_fname(pg_hsh, *keys)
    pg_hsh.dig(*keys).try(:field_name)
  end

  def assign_or_merge(h, k,  k2, v)
    if h.has_key?(k)
      h[k].merge!({k2=>v})
    else
      h.merge!({k=>{k2=>v}})
    end
  end

  def to_hsh(keys)
    keys.map{|k| [k,{}]}.to_h
  end

  def compact_hsh(h)
    h.reject{|k, v| v.blank?}
  end

  def map_merge(dkeys, k, v, store)
    dkeys.map{|key| store[key].merge!({k=>v})}
  end

  # string formatting methods: #################################################
  def tagline_cap(context, media_val, media_key)
    if %w[tagline search_tagline].include?(context) && %w[artist_name title dimension].exclude?(media_key)
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

  def format_vowel(word, exception_set=[])
    %w[a e i o u].include?(word.first.downcase) && exception_set.exclude?(word) ? 'an' : 'a'
  end

  def decamelize(name)
    name.underscore.split('_').join(' ')
  end

  def cap_char?(word)
    ('A'..'Z').detect{|i| word.index(i)}
  end

  def slice_acronym(word)
    if char = cap_char?(word)
      word[word.index(char)..word.length-1].split('').take_while{|i| cap_char?(i)}.join('')
    end
  end

  # string/array detection methods: ############################################
  def included_set?(str, set)
    str.split(' ').any?{|i| set.include?(i)}
  end

  def patt_exist?(set,str)
    str && set.any?{|i| str.index(i)}
  end

  def detect_and_sub(str, sets)
    return if str.nil?
    if set = sets.detect{|set| str.index(set[0])}
      set[-1]
    end
  end
end

#not being used
# def nil_dimensions(k)
#   attr_dimension_keys(k).map{|i| [i, nil]}.to_h
# end

  # def build_detail_mounting_hsh(mounting, dimension_for, h)
  #   h['tagline'] = 'framed' if dimension_for == 'frame'
  #   h['search_tagline'] = mounting if mounting
  #   h['body'] = "This piece comes #{mounting}." if patt_exist?(%w[fram matt gallery], mounting) #mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  # end
  #
  # def detail_mounting(h, store, k='mounting')
  #   %w[tagline search_tagline body].map{|key| store[key].merge!({k=>h[key]}) if h.has_key?(key)}
  # end
  #
  # def detail_dimension(h, store, k='dimension')
  #   %w[tagline search_tagline body].each do |key|
  #     next if !h.has_key?(key)
  #     store[key].merge!({k=>detail_body_dimension_value(key, h[key])})
  #   end
  # end
  #
  # def detail_body_dimension_value(k, dimension)
  #   k == 'body' ? "Measures approx. #{dimension.join(', ')}." : dimension
  # end

  # def detail_mounting_dimension(hsh, store)
  #   hsh = build_detail_mounting_dimension(hsh)
  #   detail_mounting(hsh['mounting'], store)
  #   detail_dimension(hsh['measurements'], store)
  # end

  # start: build_mounting_dimension methods:  ##################################
  #=> "dimensions"=>{"mounting"=>{"width"=>nil, "height"=>nil}, "material"=>{"width"=>"25", "height"=>"25"}}
  # def build_dimensions(dimension_params, hsh)
  #   #return if dimension_params.nil?
  #   dimension_params.each do |dimension_field, dimension_val|
  #     new_key, dimension_field = dimension_field.split('_')
  #     assign_or_merge(hsh, new_key, dimension_field, dimension_val)
  #     #assign_or_merge(hsh, 'dimension_for', new_key, dimension_for_value(material_ref))
  #   end
  # end


  #kill
  # def build_mounting(pg_hsh, k, new_key, fk, hsh)
  #   if mounting_ref = build_mounting_value(pg_hsh, k, fk)
  #     assign_or_merge(hsh, 'mounting_ref', new_key, mounting_ref)
  #     #puts "new_key: #{new_key}, mounting_ref: #{mounting_ref}"
  #     assign_or_merge(hsh, 'dimension_for', new_key, dimension_for_value(mounting_ref))
  #   end
  # end
  #kill
  # def build_mounting_value(pg_hsh, k, fk)
  #   if k == 'mounting' && !pg_hsh['field_sets'].has_key?(k)
  #     #build_wrapped_value(nested_fname(pg_hsh['options'], 'material_id'))
  #     detect_and_sub(nested_fname(pg_hsh['options'], 'material_id'), [['gallery','gallery wrapped'], ['stretched']])
  #   elsif pg_hsh.dig('field_sets', k) && pg_hsh['field_sets'][k].has_key?('options')
  #     nested_fname(pg_hsh['field_sets'], k, 'options', fk)
  #   elsif pg_hsh.dig('field_sets', k) && pg_hsh['field_sets'][k].has_key?(fk)
  #     nested_fname(pg_hsh['field_sets'], k, fk)
  #   end
  # end

  #kill
  # def dimension_for_value(fname)
  #   case
  #     when fname.index('fram'); 'frame'
  #     when fname == 'matted'; 'matting'
  #     #when fname.index('width') || included_set?(fname, %w[width gallery stretched]); 'image'
  #     when included_set?(fname, %w[width gallery stretched]); 'image'
  #     else fname
  #   end
  # end

  # start:  detail_mounting_dimension ########################################## method to dynamically build description keys hash
  # def build_detail_mounting_dimension(hsh, h={'measurements'=>{'tagline'=>{}, 'search_tagline'=>{}, 'body'=>[]}, 'mounting'=>{'tagline'=>{}, 'search_tagline'=>{}, 'body'=>{}}})
  #   hsh['dimensions'].each do |k, dimensions|
  #     next if dimensions.values.any?{|i| i.nil?}
  #     measurements, dimension_for = build_measurement(dimensions.values), hsh['dimension_for'][k]
  #
  #     build_detail_dimension_hsh(measurements, dimensions, dimension_for, k, h['measurements'])
  #     build_detail_mounting_hsh(hsh['mounting_ref'][k], dimension_for, h['mounting']) if k == 'mounting'
  #   end
  #   h
  # end

  # def build_detail_dimension_hsh(measurements, dimensions, dimension_for, k, h)
  #   h['tagline'] = "(#{measurements})" if oversized_values?(dimensions.values, dimension_for, k)
  #   h['search_tagline'] = "(#{measurements})" if k == 'material'
  #   h['body'] << "#{measurements} (#{dimension_for})"
  # end

# def build_product_media_hsh(product, options, store, hsh)
#   build_product_hsh(product).each do |kind, media|
#     hsh['product'].merge!({kind => build_product_media(kind, media, options)})
#   end
#   hsh['product']
# end

# START: primary methods: build_hsh; attr_hsh; detail_hsh; update fs_hsh ############


# def mounting_dimension(pg_hsh, store)
#   build_mounting_dimension(pg_hsh, hsh={'dimensions'=>{}, 'mounting_ref'=>{}, 'dimension_for'=>{}}) # hsh.dig('dimension_for', 'mounting') hsh['dimension_for']['mounting']
#   attr_dimensions(hsh['dimensions'], hsh.dig('dimension_for', 'mounting'), store)
#   detail_mounting_dimension(hsh, store)
#   update_fs_hsh(pg_hsh['field_sets'])
# end

# def build_mounting_dimension(pg_hsh, hsh)
#   %w[mounting dimension].each do |k|
#     new_key, dimension_params = k == 'dimension' ? 'material' : k, dimension_params(pg_hsh.dig('field_sets', k, 'tags'), k)
#     build_dimensions(dimension_params, hsh['dimensions'])
#     #here: next if...
#     build_mounting(pg_hsh, k, new_key, k+'_id', hsh)
#   end
#   hsh
# end
