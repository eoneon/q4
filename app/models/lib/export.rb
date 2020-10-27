class Export

  ####################### h = Export.new.csv_values_test['attrs']  <!--> Item.find(5).product_group['params']['field_sets']  h = Item.find(5).product_group['params']['options']
  # def csv_values_test
  #   item = Item.find(5)
  #   export_params(item, item.product, item.artist, item.product_group['params'])
  # end

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

  # def detail_title(store,k,v)
  #   title = v == 'Untitled' ? 'This' : "\"#{v}\""
  #   store['tagline'].merge!({k=>title}) if title != 'This'
  #   store['body'].merge!({k=>title})
  # end

  def detail_title(store,k,v)
    title = v == 'Untitled' ? 'This' : "\"#{v}\""
    store['tagline'].merge!({k=>title}) if title != 'This'
    store['search_tagline'].merge!({k=>title}) if title != 'This'
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
  #
  # def detail_category(store, k, v)
  #   store['tagline'].merge!({k=>'One-of-a-Kind'})
  #   store['body'].merge!({k=>'one-of-a-kind'})
  # end

  # def detail_material(store,k,v)
  #   return if v == 'Sericel'
  #   store['tagline'].merge!({k => "on #{tagline_material_value(v)}"}) if store['attrs']['material'] != 'Paper'
  #   store['body'].merge!({k => "on #{body_material_value(v)}"})
  # end

  def detail_material(store,k,v)
    return if v == 'Sericel'
    store['tagline'].merge!({k => "on #{tagline_material_value(v)}"}) if store['attrs']['material'] != 'Paper'
    store['search_tagline'].merge!({k => "on #{v}"})
    store['body'].merge!({k => "on #{body_material_value(v)}"})
  end

  # def detail_mounting(k, mounting, store)
  #   store['tagline'].merge!({k=>'framed'}) if mounting.split(' ').include?('framed')
  #   store['body'].merge!({k=>"This piece comes #{mounting}."}) if mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  # end

  def detail_mounting(k, mounting, store)
    store['tagline'].merge!({k=>'framed'}) if mounting.split(' ').include?('framed')
    store['search_tagline'].merge!({k=>'framed'}) if mounting.split(' ').include?('framed')
    store['body'].merge!({k=>"This piece comes #{mounting}."}) if mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  end

  # def detail_dimension(store, k, tag_set)
  #   return if tag_set.empty?
  #   punct = tag_set.count > 1 ? ', ' : ' '
  #   store['body'].merge!({k=> "Measures approx. #{tag_set.join(punct)}."})
  # end

  def detail_dimension(store, k, tag_set)
    return if tag_set.empty?
    punct = tag_set.count > 1 ? ', ' : ' '
    store['search_tagline'].merge!({k => tag_set})
    store['body'].merge!({k=> "Measures approx. #{tag_set.join(punct)}."})
  end

  # def detail_signature(store, k, v)
  #   store['tagline'].merge!({k=>tagline_signature(v)})
  #   store['body'].merge!({k=>body_signature(v)})
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

  # def detail_certificate(store, k, v)
  #   v = v == 'LOA' ? 'Letter' : 'Certificate'
  #   store['tagline'].merge!({k=> "with #{v} of Authenticity."})
  #   store['body'].merge!({k=> "Includes #{v} of Authenticity."})
  # end

  # def detail_numbering(fs_hsh, k, store)
  #   numbering, opt_numbering, tags = fs_hsh.dig(k, k+'_id').try(:field_name), fs_hsh.dig(k, 'options', k+'_id').try(:field_name), fs_hsh.dig(k, 'tags')
  #   return if !numbering || !opt_numbering
  #
  #   numbering_value = numbering_value(numbering, opt_numbering, tags)
  #   store['tagline'].merge!({k=> numbering_value})
  #   store['body'].merge!({k=> numbering_value})
  # end

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

  # mounting_dimension_hsh #####################################################
  def mounting_dimension_hsh(pg_hsh, store, hsh={'dimension'=>{}})
    mounting_hsh(pg_hsh, store)
    dimension_hsh(pg_hsh['field_sets'], store, hsh)
  end

  # mounting_hsh ###############################################################
  def mounting_hsh(pg_hsh, store, k='mounting')
    if mounting = mounting_value_case(pg_hsh, k)
      detail_mounting(k, mounting, store)
    end
  end

  def mounting_value_case(pg_hsh, k)
    if mounting = wrapped_mounting_value(pg_hsh.dig('options', 'material_id').try(:field_name))
      mounting
    elsif mounting = pg_hsh.dig('field_sets', k, 'options', k+'_id').try(:field_name)
      mounting == 'matting' ? 'matted' : mounting
    end
  end

  def wrapped_mounting_value(material)
    'gallery wrapped' if material && material.split(' ').include?('gallery')
  end

  # dimension_hsh ##############################################################
  def dimension_hsh(fs_hsh, store, hsh)
    export_dimensions(build_dimension_hsh(fs_hsh, hsh['dimension']), store)
    update_fs_hsh(fs_hsh)
  end

  def export_dimensions(d_hsh, store, hsh={}, tag_set=[])
    d_hsh.each do |d_kind, d_kind_hsh|
      dimensions, dimension_type = d_kind_hsh['dimensions'], d_kind_hsh['dimension_type']
      hsh.merge!(attr_dimensions(d_kind, dimensions, dimension_type))
      tag_set << format_dimensions(dimensions) + ' ' + "(#{dimension_type})" if dimensions.values.none?{|v| v.blank?}
    end
    hsh.each {|k,v| store['attrs'].merge!({k=>v})}
    detail_dimension(store, 'dimension', tag_set)
  end

  def build_dimension_hsh(fs_hsh, d_hsh)
    %w[mounting dimension].each do |kind|
      tags, obj = ['tags', kind+'_id'].map{|key| fs_hsh.dig(kind, key)}
      build_nested_dimension_hsh(dimension_tags(tags, kind), obj.try(:field_name), d_hsh)
    end
    d_hsh
  end

  def dimension_tags(tags, kind)
    tags ? tags : default_tags(kind)
  end

  def default_tags(kind)
    keys = kind == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end

  def build_nested_dimension_hsh(dimension_tags, fname, d_hsh)
    dimension_tags.each do |d_key, d_val|
      k, k2 = d_key.split('_')
      d_hsh[k] = {'dimension_type'=> dimension_type(fname)} if !d_hsh.has_key?(k)
      assign_or_merge(d_hsh[k], 'dimensions',  k2, d_val)
    end
    d_hsh
  end

  def dimension_type(fname)
    case fname
      when 'framing'; 'frame'
      when 'matted'; 'matting'
      when 'width & height'; 'image'
      else fname
    end
  end

  def attr_dimensions(d_kind, dimensions, dimension_type)
    if d_kind == 'mounting'
      attr_mounting_dimension(dimension_type, dimensions.transform_keys{|v| 'frame_'+v})
    else
      attr_material_dimension(dimensions)
    end
  end

  def attr_material_dimension(tags)
    return tags if tags.keys == %w[width height]
    tag_vals = tags.values
    tag_vals.count == 1 ? %w[width height].map{|k| [k, tag_vals[0]]}.to_h : %w[width height].each_with_index{|(k,v), idx| [k, tag_vals[idx]]}.to_h
  end

  def attr_mounting_dimension(dimension_type, tags)
    dimension_type == 'frame' ? tags : tags.transform_values!{|v| nil}
  end

  def format_dimensions(dimensions)
    dimensions.transform_values{|v| v+"\""}.values.join(' x ')
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
    search_tagline_key_hsh(store['tagline'].keys, hsh)
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

  def reorder_numbering_key(tagline_hsh, tagline_keys, k='numbering')
    return tagline_keys unless tagline_hsh[k] && tagline_hsh[k].split(' ')[0] == 'from'
    tagline_keys.delete(k)
    tagline_keys.insert(tagline_keys.index('material'), k)
    tagline_keys
  end

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

  def assign_or_merge(h, k,  k2, v)
    if h.has_key?(k)
      h[k].merge!({k2=>v})
    else
      h.merge!(nested_hsh(k: k, k2: k2, v: v))
    end
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
