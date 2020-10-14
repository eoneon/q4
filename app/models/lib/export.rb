class Export

  ####################### h = Export.new.csv_values_test['attrs']  <!--> Item.find(5).product_group['params']['field_sets']  h = Item.find(5).product_group['params']['options']
  def csv_values_test
    item = Item.find(5)
    export_params(item, item.product, item.artist, item.product_group['params'])
  end

  # export_params ##############################################################
  def export_params(item, product, artist, pg_hsh, store={'attrs'=>{}, 'tagline'=>{}, 'body'=>{}})
    item_hsh(item, artist, store)
    product_media_hsh(product, pg_hsh, store)
    
    mounting_dimension_hsh(pg_hsh, store)
    fs_opt_media(pg_hsh['field_sets'], store)
    detail_numbering(pg_hsh['field_sets'], 'numbering', store)
    format_description(store)
  end

  # item_hsh ###################################################################
  def item_hsh(item, artist, store, hsh={'item'=>{}})
    build_item_hsh(item, artist, store, hsh['item'])
  end

  def build_item_hsh(item, artist, store, i_hsh)
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
    store['body'].merge!({k=>title})
  end

  def detail_artist(store,k,v)
    store['tagline'].merge!({k=> "#{v},"})
    store['body'].merge!({k=> "by #{v},"})
  end

  def detail_category(store, k, v)
    store['tagline'].merge!({k=>'One-of-a-Kind'})
    store['body'].merge!({k=>'one-of-a-kind'})
  end

  def detail_material(store,k,v)
    return if v == 'Sericel'
    store['tagline'].merge!({k => "on #{tagline_material_value(v)}"}) if store['attrs']['material'] != 'Paper'
    store['body'].merge!({k => "on #{body_material_value(v)}"})
  end

  def detail_mounting(k, mounting, store)
    store['tagline'].merge!({k=>'framed'}) if mounting.split(' ').include?('framed')
    store['body'].merge!({k=>"This piece comes #{mounting}."}) if mounting.split(' ').any?{|i| ['framed', 'matted', 'gallery']}
  end

  def detail_dimension(store, k, tag_set)
    punct = tag_set.count > 1 ? ', ' : ' '
    store['body'].merge!({k=> "Measures approx. #{tag_set.join(punct)}."})
  end

  def detail_signature(store, k, v)
    store['tagline'].merge!({k=>tagline_signature(v)})
    store['body'].merge!({k=>body_signature(v)})
  end

  def detail_certificate(store, k, v)
    v = v == 'LOA' ? 'Letter' : 'Certificate'
    store['tagline'].merge!({k=> "with #{v} of Authenticity."})
    store['body'].merge!({k=> "Includes #{v} of Authenticity."})
  end

  def detail_numbering(fs_hsh, k, store)
    numbering, opt_numbering, tags = fs_hsh.dig(k, k+'_id').try(:field_name), fs_hsh.dig(k, 'options', k+'_id').try(:field_name), fs_hsh.dig(k, 'tags')
    return if !numbering || !opt_numbering
    numbering_value = numbering_value(numbering, opt_numbering, tags)
    store['tagline'].merge!({k=> numbering_value})
    store['body'].merge!({k=> numbering_value})
  end

  def default_detail(store,k,v)
    store['tagline'].merge!({k=>v.split(' ').map{|k| k.capitalize}.join(' ')})
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
      tag_set << format_dimensions(dimensions) + ' ' + "(#{dimension_type})" if dimensions.values.exclude?(nil)
    end
    hsh.each {|k,v| store['attrs'].merge!({k=>v})}
    detail_dimension(store, 'dimension', tag_set)
  end

  def build_dimension_hsh(fs_hsh, d_hsh)
    %w[dimension mounting].each do |kind|
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

  # product_media_hsh ################################################################## {"media"=>{"category"=>"Original", "medium"=>"watercolor painting", "material"=>"paper"}}
  def product_media_hsh(product, pg_hsh, store, hsh={'product'=>{}})
    return store['attrs'].merge!(default_attr_media) if product.nil?
    options = build_opt_hsh(pg_hsh['options'])
    product_media = build_product_media_hsh(product, options, store, hsh)
    export_product_media(product_media, store)
    opt_media_hsh(options, product_media, store)
  end

  def export_product_media(product_media, store)
    product_media.each do |k, media|
      store['attrs'].merge!(attr_product_media_case(k, media))
    end
  end

  def build_opt_hsh(opt_hsh, h={'opt_hsh'=>{}})
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

  #product_hsh.keys, opt_hsh.keys
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

  def fs_media_hsh(fs_hsh, hsh={'fs_media'=>{}})
    fs_hsh.each do |kind, kind_param|
      next if fs_param_case(kind_param, kind+'_id') == true
      hsh['fs_media'].merge!({kind => fname_and_or_tags(kind_param, kind+'_id')})
    end
    hsh
  end

  def fname_and_or_tags(kind_param, fk, hsh={})
    kind_param.each do |tag_key, tag_hsh|
      h = tag_key == 'options' ? {'field_name'=> tag_hsh[fk].field_name} : {'tags'=> tag_hsh}
      hsh.merge!(h)
    end
    hsh
  end

  def fs_param_case(kind_param, fk)
    case
      when kind_param.has_key?(fk) && kind_param[fk].blank?; true
      when kind_param.has_key?('options') && kind_param['options'][fk].blank?; true
      when kind_param['tags'] && kind_param['tags'].values.include?(nil); true
      when kind_param.has_key?(fk); kind_param.delete(fk)
      else kind_param
    end
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

  # Description ################################################################
  def format_description(store)
    description_keys_hsh(store).each do |context, media_keys|
      store['attrs'][context] = build_description(context, store[context], media_keys)
    end
    store
  end

  def build_description(context, media_hsh, media_keys, set=[])
    media_keys.each do |media_key|
      set << assign_media(context, media_hsh, media_keys, media_key, media_hsh[media_key])
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
      #when 'artist_name'; format_artist(context, media_val)
      when 'title'; format_title(context, media_val, media_hsh[media_keys[1]])
      when 'medium'; format_medium(context, media_key, media_val)
      when 'material'; format_material(context, media_keys, media_val)
      when 'leafing'; format_leafing(media_keys, media_val)
      when 'remarque'; format_remarque(context, media_keys, media_val)
      when 'numbering'; format_numbering(media_keys, media_val, media_val.split(' ').include?('from'))
      #when 'signature'; format_signature(context, media_keys, media_val)
      #when 'certificate'; format_certificate(media_val)
    end
  end

  # def format_artist(context, media_val)
  #   context == 'tagline' ? "#{media_val}," : "by #{media_val},"
  # end

  def format_title(context, media_val, next_media)
    context == 'tagline' ? media_val :  "#{media_val} is #{format_vowel(next_media, ['one-of-a-kind', 'unique'])}"
  end

  def format_medium(context, media_keys, media_val)
    return unless context == 'tagline'
    %w[material leafing remarque].all? {|k| media_keys.exclude?(k)} ? "#{media_val}," : media_val
  end

  def format_material(context, media_keys, media_val)
    return unless context == 'tagline' && %w[leafing remarque].all? {|i| media_keys.exclude?(i)}
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

  # def format_signature(context, media_keys, media_val)
  #   context == 'body' || context == 'tagline' && media_keys.exclude?('certificate') ? "#{media_val}" : media_val
  # end
  #
  # def format_certificate(media_val)
  #   "#{media_val}"
  # end

  ##############################################################################
  def description_keys_hsh(store)
    {'tagline' => tagline_keys(store['tagline'], store['tagline'].keys), 'body' => all_body_keys.select{|k| store['body'].has_key?(k)}}
  end

  def tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = sorted_tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = tagline_keys.reject {|k| reject_tagline_keys(tagline_hsh, k, tagline_hsh[k])}
  end

  def sorted_tagline_keys(tagline_hsh, tagline_keys)
    tagline_keys = all_title_keys.select{|k| tagline_keys.include?(k)}
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

  #
  # def stash_media(store, p_tags, medium_val)
  #   media_keys.each do |k|
  #     store['stash'][k] = media_val(k, p_tags[k], medium_val)
  #   end
  #   store
  # end
  #
  # def media_val(k, v, medium_val)
  #   k == 'medium' ? {'medium_type' => v, 'medium_opt' => medium_val} : v
  # end
  #
  # def media_opt_hsh(opt_hsh, p_hsh, store, p_media={})
  #   keys = opt_hsh.keys.include?('embellished_id') ? p_hsh.keys.prepend('embellished') : p_hsh.keys
  #   keys.each do |k|
  #     field_name = opt_hsh.has_key?(k+'_id') ? opt_hsh[k+'_id'].field_name : decamelize(p_hsh[k])
  #     p_media.merge!({k=>{'field_name'=>field_name}})
  #   end
  #   store['description'].merge!(p_media)
  # end
  #
  # def media_fs_hsh(store)
  #   store['field_sets'].each do |kind_key, kind_hsh|
  #     if h = merge_fname_or_tags(kind_key, kind_hsh, kind_key+'_id')
  #       store['description'].merge!(h)
  #     end
  #   end
  #   store
  # end
  #
  # def merge_fname_or_tags(kind_key, kind_hsh, fk, h={})
  #   kind_hsh.select{|f_key, f_hsh| f_hsh.class == Hash && f_hsh.values.none?{|v| v.blank?}}.each do |f_key, f_hsh|
  #     h.merge!({kind_key => {'field_name' => f_hsh[fk].field_name}}) if f_key == 'options'
  #     h['tags'] = f_hsh if f_key == 'tags'
  #   end
  #   h unless h.empty?
  # end
  #
  # def p_media_keys
  #   %w[category sub_category medium material]
  # end

  ##############################################################################

  # def handle_description(store, hsh={})
  #   description_hsh(store['description']).each do |context, d_keys|
  #     build_description_by_kind(d_store, context, d_keys, hsh.merge!({context =>[]}))
  #     hsh[context] = format_description_by_context(hsh[context].compact, context)
  #   end
  #   d_store.merge!(hsh)
  # end

  # def description_hsh(d_store)
  #   {'tagline' => title_keys(d_store, d_store.keys), 'body' => body_keys(d_store, d_store.keys)}
  # end

  # def build_description_by_kind(d_store, context, d_keys, hsh)
  #   d_keys.each do |k|
  #     hsh[context] << description_cases(d_store, context, k, d_store[k]['field_name'], d_store[k]['tags'], d_keys)
  #   end
  #   hsh[context].compact
  # end



  ##########################

  # def description_cases(d_store, context, k, field_name, tags, d_keys)
  #   case
  #     when k == 'artist' then format_artist(context, field_name)
  #     when k == 'title' then format_title(d_hsh, d_keys, field_name)
  #     when k == 'mounting' then format_mounting(context, field_name)
  #     when k == 'category' && field_name == 'one of a kind' then format_category(context)
  #     when k == 'medium' && context == 'tagline' then format_medium(d_keys, field_name)
  #     when k == 'material' then format_material(context, d_keys, field_name, field_name.split(' '))
  #     when k == 'leafing' then format_leafing(d_keys, field_name)
  #     when k == 'remarque' then format_remarque(context, d_keys, field_name)
  #     when k == 'numbering' then format_numbering(d_keys, field_name, tags, field_name.split(' ').include?('from'))
  #     when k == 'signature' then format_signature(context, d_keys, field_name)
  #     when k == 'certificate' then format_certificate(context, field_name)
  #     when k == 'dimension' then format_dimension(context, tags)
  #     else field_name
  #   end
  # end
  #
  # def format_description_by_context(word_set, context)
  #   word_set.map!{|words| cap_words(words)} if context == 'tagline'
  #   word_set.join(' ')
  # end
  # #######################
  #
  # def attr_values(store, attr_hsh={})
  #   store['stash'].each do |kind_key, kind_val|
  #     attr_hsh.merge!(attr_case(kind_key, kind_val))
  #   end
  #   store['export'] = attr_hsh
  # end
  #
  # def attr_case(kind_key, kind_val)
  #   case kind_key
  #     #when 'item'; kind_val.merge!({'title' => attr_title(kind_val['title'])})
  #     #when 'dimension'; attr_dimensions(kind_val)
  #     when 'category'; attr_category(kind_val)
  #     when 'medium'; attr_medium(kind_key, kind_val)
  #     when 'material'; attr_material(kind_key, kind_val)
  #     else {kind_key => kind_val}
  #   end
  # end

  # def attr_title(title)
  #   title.blank? ? 'Untitled' : title
  # end

  # def attr_dimensions(d_hsh, hsh={})
  #   d_hsh.each do |k, h|
  #     attr_dimension_case(k, h, hsh)
  #   end
  #   hsh
  # end
  #
  # def attr_dimension_case(k, h, hsh)
  #   tags = k == 'mounting' ? attr_mounting_dimension(h['dimension_type'], h['dimensions'].transform_keys{|v| 'frame_'+v}) : attr_material_dimension(h['dimensions'])
  #   hsh.merge!(tags)
  # end
  #
  # def attr_material_dimension(tags)
  #   return tags if tags.keys == %w[width height]
  #   tag_vals = tags.values
  #   tag_vals.count == 1 ? %w[width height].map{|k| [k, tag_vals[0]]}.to_h : %w[width height].each_with_index{|(k,v), idx| [k, tag_vals[idx]]}.to_h
  # end
  #
  # def attr_mounting_dimension(dimension_type, tags)
  #   dimension_type == 'frame' ? tags : tags.transform_values!{|v| nil}
  # end

  # def attr_category(v)
  #   [%w[art_type, art_category], attr_category_case(v)].transpose.to_h
  # end
  #
  # def attr_category_case(v)
  #   if ['Original', 'OneOfAKind'].include?(v)
  #     ['Original', 'Original Painting']
  #   elsif v == 'LimitedEdition'
  #     ['Limited Edition', 'Limited Edition']
  #   elsif v == 'PrintMedia'
  #     ['Print', 'Limited Edition']
  #   end
  # end

  # def attr_medium(k, m_hsh)
  #   {k => attr_medium_value_case(m_hsh)}
  # end
  #
  # def attr_medium_value_case(m_hsh)
  #   case
  #     when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(m_hsh['medium_type']); m_hsh['medium_type']
  #     when m_hsh['medium_type'] == 'Silkscreen'; 'Serigraph'
  #     when m_hsh['medium_type'].underscore.split('_').include?('painting'); attr_painting(m_hsh).capitalize
  #     when m_hsh['medium_type'].underscore.split('_').include?('drawing'); attr_drawing(m_hsh)
  #     else 'Mixed Media'
  #   end
  # end
  #
  # def attr_painting(m_hsh)
  #   case
  #   when m_hsh['medium_opt'].nil? || m_hsh['medium_opt'] == 'painting'; 'unknown'
  #   when m_hsh['medium_opt'] == 'sumi ink painting'; 'watercolor'
  #   else %w[oil acrylic watercolor pastel guache].detect {|k| m_hsh['medium_opt'] == "#{k} painting"}
  #   end
  # end
  #
  # def attr_drawing(m_hsh)
  #   if medium_opt = m_hsh['medium_opt']
  #     medium_opt.split(' ').include?('pencil') ? 'Pencil' : 'Pen and Ink'
  #   else
  #     'Pen and Ink'
  #   end
  # end
  #
  # def attr_material(kind_key, kind_val)
  #   {kind_key => attr_material_value(kind_val.underscore.split('_'))}
  # end
  #
  # def attr_material(material_split)
  #   if k = %w[canvas paper board metal sericel].detect{|k| material_split.include?(k)}
  #     k.capitalize
  #   else
  #     'Board'
  #   end
  # end
  #######################



  ####################################################
  ####################################################

  # def attr_description(store)
  # end

  ####################################################

  ####################### older methods

  # def csv_item(item, artist, store)
  #   store['csv_export'].merge!(csv_attr_and_val(item, 'item').merge(csv_attr_and_val(artist, 'artist')))
  #   csv_title(store)
  #   csv_artist(store)
  # end
  #
  # def csv_title(store)
  #   if store['csv_export']['title'].blank?
  #     store['csv_export']['title'] = 'Untitled'
  #     store['description'].merge!(nested_hsh(k: 'title', v: 'This'))
  #   else
  #     store['description'].merge!(nested_hsh(k: 'title', v: "\"#{store['csv_export']['title']}\""))
  #   end
  # end
  #
  # def csv_artist(store)
  #   store['description'].merge!(nested_hsh(k: 'artist', v: store['csv_export']['artist_name'])) if store['csv_export']['artist_name']
  # end

  ####################################################

  # def csv_product(pg_hsh, item, product, store)
  #   store['csv_export'].merge!(csv_hsh(pg_hsh, item.tags, product.tags))
  #
  #   store['description'].merge!(description_hsh(pg_hsh, product.tags, store['description']))
  #   store
  # end

  # store['description']
  # def description_builder(d_store)
  #   d_hsh = description_hsh(d_store, d_store.keys)
  #   description_attr(d_store, d_hsh)
  #   #d_store.merge!( description_hsh(d_store, d_store.keys) )
  # end
  #
  # def description_hsh(d_store, d_keys)
  #   {'tagline' => title_keys(d_store, d_keys), 'body' => body_keys(d_store, d_keys)}
  # end
  #
  # def description_attr(d_store, d_hsh)
  #   #
  # end

  # def description_hsh(pg_hsh, p_tags, d_hsh={})
  #   media_hsh(pg_hsh['options'].select{|k,v| !v.nil?}, p_tags, d_hsh)
  #   sub_media_hsh(pg_hsh['field_sets'], d_hsh)
  #   dimension_hsh(d_hsh, d_hsh.keys)
  #   #
  #   #description_builder(d_hsh, {'tagline' => title_keys(d_hsh, d_hsh.keys), 'body' => body_keys(d_hsh, d_hsh.keys)})
  #   #description_builder(d_hsh, d_hsh.keys)
  #   description_builder(d_hsh, {'tagline' => title_keys(d_hsh, d_hsh.keys), 'body' => body_keys(d_hsh, d_hsh.keys)})
  #   #d_hsh
  # end

  # def description_hsh(pg_hsh, p_tags, d_hsh={})
  #   media_hsh(pg_hsh['options'].select{|k,v| !v.nil?}, p_tags, d_hsh)
  #
  #   sub_media_hsh(pg_hsh['field_sets'], d_hsh)
  #
  #   dimension_hsh(d_hsh, d_hsh.keys)
  #   description_builder(d_hsh, {'tagline' => title_keys(d_hsh, d_hsh.keys), 'body' => body_keys(d_hsh, d_hsh.keys)})
  # end

  # def media_hsh(opt_hsh, p_tags, d_hsh)
  #   %w[embellished category sub_category medium material].each do |kind|
  #     merge_media_to_hsh(opt_hsh, p_tags, d_hsh, kind)
  #   end
  #   d_hsh
  # end
  #
  # def merge_media_to_hsh(opt_hsh, p_tags, d_hsh, kind)
  #   if opt_hsh.has_key?(kind+'_id')
  #     f_hsh_from_source_hsh(opt_hsh[kind+'_id'], d_hsh, kind)
  #   elsif p_tags.has_key?(kind) && p_tags[kind] != 'n/a'
  #     f_hsh_from_from_product_hsh(d_hsh, p_tags, kind)
  #   end
  # end
  #
  # def sub_media_hsh(fs_hsh, d_hsh)
  #   fs_hsh.each do |kind, kind_hsh|
  #     merge_options_and_tags_hsh(kind_hsh, d_hsh, kind)
  #   end
  #   d_hsh
  # end
  #
  # def merge_options_and_tags_hsh(kind_hsh, d_hsh, kind)
  #   %w[options tags].each do |f_key|
  #     next if !kind_hsh.dig(f_key) || kind_hsh.dig(f_key).values.any?{|v| v.blank?}
  #     f_hsh_from_source_hsh(kind_hsh.dig(f_key, kind+'_id'), d_hsh, kind) if f_key == 'options'
  #     tags_hsh(kind_hsh.dig(f_key), d_hsh, kind, 'tags') if f_key == 'tags'
  #   end
  #   d_hsh
  # end
  #
  # def f_hsh_from_source_hsh(obj, d_hsh, k)
  #   d_hsh.merge!(nested_hsh(k: k, v: obj.field_name))
  # end
  #
  # def f_hsh_from_from_product_hsh(d_hsh, p_tags, k)
  #   d_hsh.merge!(nested_hsh(k: k, v: p_tags[k].underscore.split('_').join(' '))) #reject 'standard'
  # end
  #
  # def tags_hsh(tags_hsh, d_hsh, *keys)
  #   if d_hsh.has_key?(keys[0])
  #     d_hsh[keys[0]][keys[1]] = tags_hsh
  #   else
  #     d_hsh[keys[0]] = {keys[1] => tags_hsh}
  #   end
  # end

  ####################################################

  # def dimension_hsh(d_hsh, d_keys, tag_set=[])
  #   %w[mounting dimension].each do |k|
  #     if d_keys.include?(k) && d_hsh.dig(k, 'tags')
  #       k_tags, tag_keys_split = d_hsh[k]['tags'], d_hsh.dig(k, 'tags').keys.map{|tag_key| tag_key.split('_')}.flatten
  #       tag_set << [format_dimensions(k_tags), format_dimension_type(d_hsh[k], tag_keys_split)].join(' ')
  #     end
  #   end
  #   punct = tag_set.count > 1 ? ', ' : ' '
  #   d_hsh['dimension']['tags']['body'] = "Measures approx. #{tag_set.join(punct)}." unless tag_set.empty?
  # end
  #
  # def format_dimension_type(kind_hsh, tag_keys_split)
  #   if tag_keys_split[0] == 'material'
  #     material_dimension(tag_keys_split)
  #   elsif tag_keys_split[0] == 'mounting'
  #     mounting_dimension(kind_hsh['field_name'])
  #   end
  # end
  #
  # def format_dimensions(tags)
  #   tags.transform_values{|v| v+"\""}.values.join(' x ')
  # end
  #
  # def mounting_dimension(field_name)
  #   case
  #     when field_name == 'framed'; "(frame)"
  #     when field_name == 'matted'; "(matting)"
  #     when field_name == 'border'; "(border)"
  #   end
  # end
  #
  # def material_dimension(tags_keys_split)
  #   tags_keys_split.include?('image-diameter') ? "(image-diameter)" : "(image)"
  # end

  #refactored methods for building description #################################
  # def description_builder(d_hsh, d_keys, hsh={})
  #   {'tagline' => title_keys(d_hsh, d_keys), 'body' => body_keys(d_hsh, d_keys)}.each do |context, d_keys|
  #     build_description_by_kind(d_hsh, context, d_keys, hsh.merge!({context =>[]}))
  #     hsh[context] = format_description_by_context(hsh[context].compact, context)
  #   end
  #   hsh
  # end

  # def description_builder(d_hsh, d_keys_hsh, hsh={})
  #   d_keys_hsh.each do |context, d_keys|
  #     build_description_by_kind(d_hsh, context, d_keys, hsh.merge!({context =>[]}))
  #     hsh[context] = format_description_by_context(hsh[context].compact, context)
  #   end
  #   d_hsh.merge!(hsh)
  # end
  #
  # def build_description_by_kind(d_hsh, context, d_keys, hsh)
  #   d_keys.each do |k|
  #     hsh[context] << description_cases(d_hsh, context, k, d_hsh[k]['field_name'], d_hsh[k]['tags'], d_keys)
  #   end
  #   hsh[context].compact
  # end
  #
  # def format_description_by_context(word_set, context)
  #   word_set.map!{|words| cap_words(words)} if context == 'tagline'
  #   word_set.join(' ')
  # end
  #
  # def description_cases(d_hsh, context, k, field_name, tags, d_keys)
  #   case
  #     when k == 'artist' then format_artist(context, field_name)
  #     when k == 'title' then format_title(d_hsh, d_keys, field_name)
  #     when k == 'mounting' then format_mounting(context, field_name)
  #     when k == 'category' && field_name == 'one of a kind' then format_category(context)
  #     when k == 'medium' && context == 'tagline' then format_medium(d_keys, field_name)
  #     when k == 'material' then format_material(context, d_keys, field_name, field_name.split(' '))
  #     when k == 'leafing' then format_leafing(d_keys, field_name)
  #     when k == 'remarque' then format_remarque(context, d_keys, field_name)
  #     when k == 'numbering' then format_numbering(d_keys, field_name, tags, field_name.split(' ').include?('from'))
  #     when k == 'signature' then format_signature(context, d_keys, field_name)
  #     when k == 'certificate' then format_certificate(context, field_name)
  #     when k == 'dimension' then format_dimension(context, tags)
  #     else field_name
  #   end
  # end
  #
  # # description_cases methods for building description #########################
  #
  # def format_artist(context, field_name)
  #   context == 'tagline' ? "#{field_name}," : "by #{field_name},"
  # end
  #
  # def format_title(d_hsh, d_keys, field_name)
  #   word = d_hsh[d_keys[d_keys.index('title')+1]]['field_name']
  #   "#{field_name} is #{format_vowel(word, ['one-of-a-kind', 'unique'])}"
  # end
  #
  # def format_mounting(context, field_name)
  #   if context == 'tagline' && field_name.split(' ').include?('framed')
  #     'framed'
  #   elsif context == 'body' && field_name.split(' ').any?{|i| ['framed', 'matted']}
  #     "This piece comes #{field_name}."
  #   end
  # end
  #
  # def format_medium(d_keys, field_name)
  #    %w[material leafing remarque].all? {|k| d_keys.exclude?(k)} ? "#{field_name}," : field_name
  # end
  #
  # def format_category(context)
  #   context == 'tagline' ? 'One-of-a-Kind' : 'one-of-a-kind'
  # end
  #
  # def format_material(context, d_keys, field_name, split_field_name)
  #   return if context == 'tagline' && split_field_name.include?('paper')
  #   field_name = 'canvas' if context == 'tagline' && split_field_name.include?('stretched')
  #   field_name = 'canvas' if context == 'body' && split_field_name.include?('gallery')
  #   punct = ',' if %w[leafing remarque].all? {|i| d_keys.exclude?(i)} && context == 'tagline'
  #   "on #{[field_name, punct].join('')}"
  # end
  #
  # def format_leafing(d_keys, field_name)
  #   punct = ',' if d_keys.exclude?('remarque')
  #   "with #{[field_name, punct].join('')}"
  # end
  #
  # def format_remarque(context, d_keys, field_name)
  #   word = d_keys.include?('leafing') ? 'and' : 'with'
  #   field_name = field_name+',' #if context == 'title'
  #   "#{word} #{field_name}"
  # end
  #
  # def format_numbering(d_keys, field_name, tags, proof_ed)
  #   if proof_ed && d_keys.include?('material')
  #     field_name
  #   elsif proof_ed && %w[leafing remarque].all? {|k| d_keys.exclude?(k)}
  #     "#{field_name},"
  #   elsif !proof_ed
  #     word = 'and' if d_keys.include?('signature')
  #     words = tags ? "#{field_name} #{tags.values.join('/')}" : field_name
  #     [words, word].join(' ')
  #   end
  # end
  #
  # def format_signature(context, d_keys, field_name)
  #   context == 'tagline' ? title_signature(d_keys, field_name) : body_signature(d_keys, field_name)
  # end
  #
  # def title_signature(d_keys, field_name)
  #   field_name = field_name.split(' ').include?('authorized') ? 'signed' : field_name
  #   punct = '.' if d_keys.exclude?('certificate')
  #   [field_name, punct].join('')
  # end
  #
  # def body_signature(d_keys, field_name)
  #   if k = %w[plate authorized].detect{|k| field_name.split(' ').include?(k)}
  #     "bearing the #{k} signature of the artist."
  #   elsif field_name.split(' ').include?('estate')
  #     "#{field_name}."
  #   else
  #     "#{field_name} by the artist."
  #   end
  # end
  #
  # def format_certificate(context, field_name)
  #   field_name = field_name == 'LOA' ? 'Letter' : 'Certificate'
  #   word = context == 'tagline' ? 'with' : 'Includes'
  #   [word, field_name, 'of Authenticity.'].join(' ')
  # end
  #
  # def format_dimension(context, tags)
  #   tags['body'] if context == 'body'
  # end

  # title_keys #################################################################
  def title_keys(d_store, d_keys)
    #tagline_keys = reorder_tagline_keys_case(d_store, all_title_keys.select{|k| d_store.has_key?(k)})
    tagline_keys = reorder_tagline_keys_case(d_store, all_title_keys.select{|k| d_keys.include?(k)})
    tagline_keys.reject {|k| reject_title_keys_cases(d_store, d_keys, k, d_store[k]['field_name'])}
  end

  def reorder_tagline_keys_case(d_store, tagline_keys)
    if k = tagline_keys.detect{|k| k == 'numbering' && d_store.dig(k, 'field_name') && d_store[k]['field_name'].split(' ')[0] == 'from'}
      reorder_numbering_key(k, tagline_keys)
    else
      tagline_keys
    end
  end

  # def reorder_numbering_key(k, tagline_keys)
  #   tagline_keys.delete(k)
  #   tagline_keys.insert(tagline_keys.index('material'), k)
  #   tagline_keys
  # end

  def reject_title_keys_cases(d_store, d_keys, k, field_name)
    case k
      when 'medium' && field_name.split(' ').include?('giclee') && d_store['material']['field_name'].split(' ').exclude?('paper'); true
      when 'material' && field_name.split(' ').include?('paper'); true
      #when 'title' && field_name[0] != "\""; true
      when 'title' && field_name == 'Untitled'; true
      else false
    end
  end

  # def export_keys
  #   %w[sku artist tag_line medium material width]
  # end

  def all_title_keys
    %w[artist title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate]
  end

  # body_keys ##################################################################

  def body_keys(d_store, d_keys)
    all_body_keys.select{|k| d_keys.include?(k)}
    #all_body_keys.select{|k| d_store.has_key?(k)}
    #reorder_tagline_keys_case(d_store, all_body_keys.select{|k| d_store.has_key?(k)})
    # reorder_title_keys(d_store, all_body_keys).reject {|k| reject_body_keys(d_store, d_keys, k)}
  end

  # def reject_body_keys(d_store, d_keys, k)
  #   d_keys.exclude?(k)
  # end

  # def all_body_keys
  #   %w[title embellished category sub_category medium material leafing remarque artist numbering signature mounting certificate dimension]
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

  def cap_words(words, set=[])
    return set << words if words && words[0] == "\""
    format_word_set(words.split(' '), set)
  end

  def format_word_set(word_set, set)
    word_set.each do |word|
      set << cap_case(word)
    end
    set.join(' ')
  end

  def cap_case(word)
    if ('A'..'Z').include?(word[0]) || %w[a an and from with].include?(word)
      word
    else
      word.capitalize
    end
  end

  def decamelize(name)
    name.underscore.split('_').join(' ')
  end
  ####################################################
  ####################################################

  # csv hsh ###################################################
  # def csv_hsh(store['stash']['medium'], i_tags, p_tags, attr_hsh={})
  # def csv_hsh(pg_hsh['options']['medium_id'].try(:field_name), i_tags, p_tags, attr_hsh={})

  # def csv_hsh(pg_hsh, i_tags, p_tags, csv_hsh={})
  #   pg_hsh = {'mounting' => pg_hsh['field_sets']['mounting']['mounting_id'].try(:field_name), 'medium'=> pg_hsh['options']['medium_id'].try(:field_name)}
  #   csv_hsh.merge!(csv_media(p_tags, pg_hsh['medium']))
  #   csv_hsh.merge!(csv_dimensions(i_tags, pg_hsh['mounting']))
  #   csv_hsh
  # end

  # csv dimensions ###################################################

  # def csv_dimensions(i_tags, mounting_val)
  #   dimension_keys.map {|k| format_csv_dimension_hsh(k.split('_'), i_tags.try(:[], k), mounting_val)}.to_h
  # end
  #
  # def format_csv_dimension_hsh(split_key, val, mounting_val)
  #   kind, dimension = split_key
  #   [csv_dimension_key(dimension, kind), csv_dimension_val(kind, val, mounting_val)]
  # end
  #
  # def csv_dimension_key(dimension, kind)
  #   kind == 'material' ? dimension : ['frame', dimension].join('_')
  # end
  #
  # def csv_dimension_val(kind, val, mounting_val)
  #   return if val.nil?
  #   kind == 'material' ? val.to_i : frame_dimensions(val, mounting_val)
  # end
  #
  # def frame_dimensions(val, mounting_val)
  #   val.to_i if val && mounting_val == 'framing'
  # end
  #
  # def dimension_keys
  #   %w[material_width material_height mounting_width mounting_height]
  # end

  # def media_keys
  #   %w[category medium material]
  # end

  # update THIS ################################################################

  def csv_sorted_keys
    %w[item artist dimension media description].map{|k| csv_target_key_set(k)}.flatten(1).sort {|a,b| a[0] <=> b[0]}.map{|set| set[1]}
  end

  def attr_product_keys
    %w[media dimension description].map{|k| csv_target_key_set(k)}.flatten(1).map{|set| set[1]}
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



# def description_builder(d_store, d_hsh, hsh={})
#   d_hsh.each do |context, d_keys|
#     build_description_by_kind(d_store, context, d_keys, hsh.merge!({context =>[]}))
#     hsh[context] = format_description_by_context(hsh[context].compact, context)
#   end
#   # hsh['tagline'], hsh['body']
#   d_store.merge!(hsh)
# end
