class Export
  # Item.find(5).product_group['params']['options']
  # h = Item.find(5).product_group['params']['field_sets']

  # Item.find(5).product_group
  # item = Item.find(5)
  # Export.new.csv_values(item, item.product, item.artist, item.product_group['params'])
  # Export.new.stash_dimensions(Item.find(5).product_group['params']['field_sets'])

  # Export.new.stash_item(Item.find(5), Item.find(5).artist)

  #def csv_values(item, product, artist, pg_hsh, store={'csv_export'=>{}, 'description'=>{}})
  # def csv_values(item, product, artist, pg_hsh, store={'stash'=>{}, 'csv_export'=>{}, 'description'=>{}})
  #   # store['csv_export'].merge!(csv_attr_and_val(item, 'item').merge(csv_attr_and_val(artist, 'artist')))
  #   # csv_title(store)
  #   # csv_artist(store)
  #   # i_tags = item.tags
  #   #puts "d_hsh: #{stash_dimensions(pg_hsh[''], h={})}"
  #
  #   if product
  #     csv_product(pg_hsh, item, product, store)
  #   else
  #     store['csv_export'].merge!(attr_product_keys.map{|k| [k, nil]}.to_h)
  #   end
  #   store
  # end

  ####################### h = Export.new.csv_values_test['export']
  def csv_values_test
    item = Item.find(5)
    csv_values(item, item.product, item.artist, item.product_group['params'])
  end

  def csv_values(item, product, artist, store)
    stash_item(item, artist, store)
    attr_product(item, product, store)
    store
  end

  def attr_product(item, product, store)
    return attr_values(store).merge!(attr_product_keys.map{|k| [k, nil]}.to_h) if product.nil?
    stash_dimensions(store)
    stash_media(store, product.tags, store['options']['medium_id'].try(:field_name))
    media_opt_hsh(store['options'].select{|k,v| !v.nil?}, p_media_keys.map{|k| [k, product.tags[k]]}.to_h.reject{|k,v| v == 'n/a'}, store)
    media_fs_hsh(store)
    attr_values(store)
    title_keys(store['description'], store['description'].keys)
  end

  def stash_item(item, artist, store, h={})
    store['stash'] = {'item' => h.merge!(csv_attr_and_val(item, 'item').merge(csv_attr_and_val(artist, 'artist')))}
  end

  def stash_dimensions(store, h={})
    %w[dimension mounting].each do |k|
      tags, obj = ['tags', k+'_id'].map{|k2| store['field_sets'].dig(k, k2)}
      stash_dimension_hsh(default_tags(tags, k), obj.try(:field_name), h)
    end
    store['field_sets'].merge!({'dimension' => {'tags' => h}})
    store['field_sets']['mounting'].delete('tags')
    store['field_sets'].merge!({'mounting' => {'options' => store['field_sets']['mounting']}})
    store['stash'].merge!({'dimension' => h})
  end

  def default_tags(tags, k)
    return tags if tags
    keys = k == 'dimension' ? %w[material_width material_height] : %w[mounting_width mounting_height]
    keys.map{|k| [k, nil]}.to_h
  end

  def stash_dimension_hsh(d_tags, d_type, h)
    d_tags.each do |d_key, d_val|
      k, k2 = d_key.split('_')
      h[k] = {'dimension_type'=> dimension_type(d_type)} if !h.has_key?(k)
      assign_or_merge(h[k], 'dimensions',  k2, d_val)
    end
    h
  end

  def dimension_type(field_name)
    case field_name
      when 'framing'; 'frame'
      when 'matted'; 'matting'
      when 'width & height'; 'image'
      else field_name
    end
  end

  def stash_media(store, p_tags, medium_val)
    media_keys.each do |k|
      store['stash'][k] = media_val(k, p_tags[k], medium_val)
    end
    store
  end

  def media_val(k, v, medium_val)
    k == 'medium' ? {'medium_type' => v, 'medium_opt' => medium_val} : v
  end

  #######################
  def attr_values(store, attr_hsh={})
    store['stash'].each do |kind_key, kind_val|
      attr_hsh.merge!(attr_case(kind_key, kind_val))
    end
    store['export'] = attr_hsh
  end

  def attr_case(kind_key, kind_val)
    case kind_key
      when 'item'; kind_val.merge!({'title' => attr_title(kind_val['title'])})
      when 'dimension'; attr_dimensions(kind_val)
      when 'category'; attr_category(kind_val)
      when 'medium'; attr_medium(kind_key, kind_val)
      else {kind_key => kind_val}
    end
  end

  def attr_title(title)
    title.blank? ? 'Untitled' : title
  end

  def attr_dimensions(d_hsh, hsh={})
    d_hsh.each do |k, h|
      attr_dimension_case(k, h, hsh)
    end
    hsh
  end

  def attr_dimension_case(k, h, hsh)
    tags = k == 'mounting' ? attr_mounting_dimension(h['dimension_type'], h['dimensions'].transform_keys{|v| 'frame_'+v}) : attr_material_dimension(h['dimensions'])
    hsh.merge!(tags)
  end

  def attr_material_dimension(tags)
    return tags if tags.keys == %w[width height]
    tag_vals = tags.values
    tag_vals.count == 1 ? %w[width height].map{|k| [k, tag_vals[0]]}.to_h : %w[width height].each_with_index{|(k,v), idx| [k, tag_vals[idx]]}.to_h
  end

  def attr_mounting_dimension(dimension_type, tags)
    dimension_type == 'frame' ? tags : tags.transform_values!{|v| nil}
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

  def attr_medium(k, m_hsh)
    {k => attr_medium_value_case(m_hsh)}
  end

  def attr_medium_value_case(m_hsh)
    case
      when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(m_hsh['medium_type']); m_hsh['medium_type']
      when m_hsh['medium_type'] == 'Silkscreen'; 'Serigraph'
      when m_hsh['medium_type'].underscore.split('_').include?('painting'); attr_painting(m_hsh).capitalize
      when m_hsh['medium_type'].underscore.split('_').include?('drawing'); attr_drawing(m_hsh)
      else 'Mixed Media'
    end
  end

  def attr_painting(m_hsh)
    case
    when m_hsh['medium_opt'].nil? || m_hsh['medium_opt'] == 'painting'; 'unknown'
    when m_hsh['medium_opt'] == 'sumi ink painting'; 'watercolor'
    else %w[oil acrylic watercolor pastel guache].detect {|k| m_hsh['medium_opt'] == "#{k} painting"}
    end
  end

  def attr_drawing(m_hsh)
    if medium_opt = m_hsh['medium_opt']
      medium_opt.split(' ').include?('pencil') ? 'Pencil' : 'Pen and Ink'
    else
      'Pen and Ink'
    end
  end

  #######################

  def media_opt_hsh(opt_hsh, p_hsh, store, p_media={})
    keys = opt_hsh.keys.include?('embellished_id') ? p_hsh.keys.prepend('embellished') : p_hsh.keys
    keys.each do |k|
      field_name = opt_hsh.has_key?(k+'_id') ? opt_hsh[k+'_id'].field_name : decamelize(p_hsh[k])
      p_media.merge!({k=>{'field_name'=>field_name}})
    end
    store['description'] = p_media
  end

  def media_fs_hsh(store)
    store['field_sets'].each do |kind_key, kind_hsh|
      if h = merge_fname_or_tags(kind_key, kind_hsh, kind_key+'_id')
        store['description'].merge!(h)
      end
    end
    store
  end

  def merge_fname_or_tags(kind_key, kind_hsh, fk, h={})
    kind_hsh.select{|f_key, f_hsh| f_hsh.class == Hash && f_hsh.values.none?{|v| v.blank?}}.each do |f_key, f_hsh|
      h.merge!({kind_key => {'field_name' => f_hsh[fk].field_name}}) if f_key == 'options'
      h['tags'] = f_hsh if f_key == 'tags'
    end
    h unless h.empty?
  end

  def p_media_keys
    %w[category sub_category medium material]
  end

  ####################################################
  ####################################################

  def attr_description(store)
  end

  ####################################################

  ####################### older methods

  def csv_item(item, artist, store)
    store['csv_export'].merge!(csv_attr_and_val(item, 'item').merge(csv_attr_and_val(artist, 'artist')))
    csv_title(store)
    csv_artist(store)
  end

  def csv_title(store)
    if store['csv_export']['title'].blank?
      store['csv_export']['title'] = 'Untitled'
      store['description'].merge!(nested_hsh(k: 'title', v: 'This'))
    else
      store['description'].merge!(nested_hsh(k: 'title', v: "\"#{store['csv_export']['title']}\""))
    end
  end

  def csv_artist(store)
    store['description'].merge!(nested_hsh(k: 'artist', v: store['csv_export']['artist_name'])) if store['csv_export']['artist_name']
  end

  ####################################################

  def csv_product(pg_hsh, item, product, store)
    store['csv_export'].merge!(csv_hsh(pg_hsh, item.tags, product.tags))

    store['description'].merge!(description_hsh(pg_hsh, product.tags, store['description']))
    store
  end

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

  def description_hsh(pg_hsh, p_tags, d_hsh={})
    media_hsh(pg_hsh['options'].select{|k,v| !v.nil?}, p_tags, d_hsh)

    sub_media_hsh(pg_hsh['field_sets'], d_hsh)

    dimension_hsh(d_hsh, d_hsh.keys)
    description_builder(d_hsh, {'tagline' => title_keys(d_hsh, d_hsh.keys), 'body' => body_keys(d_hsh, d_hsh.keys)})
  end

  def media_hsh(opt_hsh, p_tags, d_hsh)
    %w[embellished category sub_category medium material].each do |kind|
      merge_media_to_hsh(opt_hsh, p_tags, d_hsh, kind)
    end
    d_hsh
  end

  def merge_media_to_hsh(opt_hsh, p_tags, d_hsh, kind)
    if opt_hsh.has_key?(kind+'_id')
      f_hsh_from_source_hsh(opt_hsh[kind+'_id'], d_hsh, kind)
    elsif p_tags.has_key?(kind) && p_tags[kind] != 'n/a'
      f_hsh_from_from_product_hsh(d_hsh, p_tags, kind)
    end
  end

  def sub_media_hsh(fs_hsh, d_hsh)
    fs_hsh.each do |kind, kind_hsh|
      merge_options_and_tags_hsh(kind_hsh, d_hsh, kind)
    end
    d_hsh
  end

  def merge_options_and_tags_hsh(kind_hsh, d_hsh, kind)
    %w[options tags].each do |f_key|
      next if !kind_hsh.dig(f_key) || kind_hsh.dig(f_key).values.any?{|v| v.blank?}
      f_hsh_from_source_hsh(kind_hsh.dig(f_key, kind+'_id'), d_hsh, kind) if f_key == 'options'
      tags_hsh(kind_hsh.dig(f_key), d_hsh, kind, 'tags') if f_key == 'tags'
    end
    d_hsh
  end

  def f_hsh_from_source_hsh(obj, d_hsh, k)
    d_hsh.merge!(nested_hsh(k: k, v: obj.field_name))
  end

  def f_hsh_from_from_product_hsh(d_hsh, p_tags, k)
    d_hsh.merge!(nested_hsh(k: k, v: p_tags[k].underscore.split('_').join(' '))) #reject 'standard'
  end

  def tags_hsh(tags_hsh, d_hsh, *keys)
    if d_hsh.has_key?(keys[0])
      d_hsh[keys[0]][keys[1]] = tags_hsh
    else
      d_hsh[keys[0]] = {keys[1] => tags_hsh}
    end
  end

  ####################################################

  def dimension_hsh(d_hsh, d_keys, tag_set=[])
    %w[mounting dimension].each do |k|
      if d_keys.include?(k) && d_hsh.dig(k, 'tags')
        k_tags, tag_keys_split = d_hsh[k]['tags'], d_hsh.dig(k, 'tags').keys.map{|tag_key| tag_key.split('_')}.flatten
        tag_set << [format_dimensions(k_tags), format_dimension_type(d_hsh[k], tag_keys_split)].join(' ')
      end
    end
    punct = tag_set.count > 1 ? ', ' : ' '
    d_hsh['dimension']['tags']['body'] = "Measures approx. #{tag_set.join(punct)}." unless tag_set.empty?
  end

  def format_dimension_type(kind_hsh, tag_keys_split)
    if tag_keys_split[0] == 'material'
      material_dimension(tag_keys_split)
    elsif tag_keys_split[0] == 'mounting'
      mounting_dimension(kind_hsh['field_name'])
    end
  end

  def format_dimensions(tags)
    tags.transform_values{|v| v+"\""}.values.join(' x ')
  end

  def mounting_dimension(field_name)
    case
      when field_name == 'framed'; "(frame)"
      when field_name == 'matted'; "(matting)"
      when field_name == 'border'; "(border)"
    end
  end

  def material_dimension(tags_keys_split)
    tags_keys_split.include?('image-diameter') ? "(image-diameter)" : "(image)"
  end

  #refactored methods for building description #################################
  # def description_builder(d_hsh, d_keys, hsh={})
  #   {'tagline' => title_keys(d_hsh, d_keys), 'body' => body_keys(d_hsh, d_keys)}.each do |context, d_keys|
  #     build_description_by_kind(d_hsh, context, d_keys, hsh.merge!({context =>[]}))
  #     hsh[context] = format_description_by_context(hsh[context].compact, context)
  #   end
  #   hsh
  # end

  def description_builder(d_hsh, d_keys_hsh, hsh={})
    d_keys_hsh.each do |context, d_keys|
      build_description_by_kind(d_hsh, context, d_keys, hsh.merge!({context =>[]}))
      hsh[context] = format_description_by_context(hsh[context].compact, context)
    end
    d_hsh.merge!(hsh)
  end

  def build_description_by_kind(d_hsh, context, d_keys, hsh)
    d_keys.each do |k|
      hsh[context] << description_cases(d_hsh, context, k, d_hsh[k]['field_name'], d_hsh[k]['tags'], d_keys)
    end
    hsh[context].compact
  end

  def format_description_by_context(word_set, context)
    word_set.map!{|words| cap_words(words)} if context == 'tagline'
    word_set.join(' ')
  end

  def description_cases(d_hsh, context, k, field_name, tags, d_keys)
    case
      when k == 'artist' then format_artist(context, field_name)
      when k == 'title' then format_title(d_hsh, d_keys, field_name)
      when k == 'mounting' then format_mounting(context, field_name)
      when k == 'category' && field_name == 'one of a kind' then format_category(context)
      when k == 'medium' && context == 'tagline' then format_medium(d_keys, field_name)
      when k == 'material' then format_material(context, d_keys, field_name, field_name.split(' '))
      when k == 'leafing' then format_leafing(d_keys, field_name)
      when k == 'remarque' then format_remarque(context, d_keys, field_name)
      when k == 'numbering' then format_numbering(d_keys, field_name, tags, field_name.split(' ').include?('from'))
      when k == 'signature' then format_signature(context, d_keys, field_name)
      when k == 'certificate' then format_certificate(context, field_name)
      when k == 'dimension' then format_dimension(context, tags)
      else field_name
    end
  end

  # description_cases methods for building description #########################

  def format_artist(context, field_name)
    context == 'tagline' ? "#{field_name}," : "by #{field_name},"
  end

  def format_title(d_hsh, d_keys, field_name)
    word = d_hsh[d_keys[d_keys.index('title')+1]]['field_name']
    "#{field_name} is #{format_vowel(word, ['one-of-a-kind', 'unique'])}"
  end

  def format_mounting(context, field_name)
    if context == 'tagline' && field_name.split(' ').include?('framed')
      'framed'
    elsif context == 'body' && field_name.split(' ').any?{|i| ['framed', 'matted']}
      "This piece comes #{field_name}."
    end
  end

  def format_medium(d_keys, field_name)
     %w[material leafing remarque].all? {|k| d_keys.exclude?(k)} ? "#{field_name}," : field_name
  end

  def format_category(context)
    context == 'tagline' ? 'One-of-a-Kind' : 'one-of-a-kind'
  end

  def format_material(context, d_keys, field_name, split_field_name)
    return if context == 'tagline' && split_field_name.include?('paper')
    field_name = 'canvas' if context == 'tagline' && split_field_name.include?('stretched')
    field_name = 'canvas' if context == 'body' && split_field_name.include?('gallery')
    punct = ',' if %w[leafing remarque].all? {|i| d_keys.exclude?(i)} && context == 'tagline'
    "on #{[field_name, punct].join('')}"
  end

  def format_leafing(d_keys, field_name)
    punct = ',' if d_keys.exclude?('remarque')
    "with #{[field_name, punct].join('')}"
  end

  def format_remarque(context, d_keys, field_name)
    word = d_keys.include?('leafing') ? 'and' : 'with'
    field_name = field_name+',' #if context == 'title'
    "#{word} #{field_name}"
  end

  def format_numbering(d_keys, field_name, tags, proof_ed)
    if proof_ed && d_keys.include?('material')
      field_name
    elsif proof_ed && %w[leafing remarque].all? {|k| d_keys.exclude?(k)}
      "#{field_name},"
    elsif !proof_ed
      word = 'and' if d_keys.include?('signature')
      words = tags ? "#{field_name} #{tags.values.join('/')}" : field_name
      [words, word].join(' ')
    end
  end

  def format_signature(context, d_keys, field_name)
    context == 'tagline' ? title_signature(d_keys, field_name) : body_signature(d_keys, field_name)
  end

  def title_signature(d_keys, field_name)
    field_name = field_name.split(' ').include?('authorized') ? 'signed' : field_name
    punct = '.' if d_keys.exclude?('certificate')
    [field_name, punct].join('')
  end

  def body_signature(d_keys, field_name)
    if k = %w[plate authorized].detect{|k| field_name.split(' ').include?(k)}
      "bearing the #{k} signature of the artist."
    elsif field_name.split(' ').include?('estate')
      "#{field_name}."
    else
      "#{field_name} by the artist."
    end
  end

  def format_certificate(context, field_name)
    field_name = field_name == 'LOA' ? 'Letter' : 'Certificate'
    word = context == 'tagline' ? 'with' : 'Includes'
    [word, field_name, 'of Authenticity.'].join(' ')
  end

  def format_dimension(context, tags)
    tags['body'] if context == 'body'
  end

  # title_keys #################################################################
  def title_keys(d_store, d_keys)
    tagline_keys = reorder_tagline_keys_case(d_store, all_title_keys.select{|k| d_store.has_key?(k)})
    tagline_keys.reject {|k| reject_title_keys_cases(d_store, d_keys, k, d_store[k]['field_name'])}
    puts "tagline_keys: #{tagline_keys}"
  end

  # def title_keys(d_store, d_keys)
  #   tagline_keys = reorder_tagline_keys_case(d_store, all_title_keys.select{|k| d_store.has_key?(k)})
  #   reject_title_keys(d_store, d_keys, tagline_keys)
  # end

  def reorder_tagline_keys_case(d_store, tagline_keys)
    if k = tagline_keys.detect{|k| k == 'numbering' && d_store.dig(k, 'field_name') && d_store[k]['field_name'].split(' ')[0] == 'from'}
      reorder_numbering_key(k, tagline_keys)
    else
      tagline_keys
    end
  end

  def reorder_numbering_key(k, tagline_keys)
    tagline_keys.delete(k)
    tagline_keys.insert(tagline_keys.index('material'), k)
    tagline_keys
  end

  def reject_title_keys(d_store, d_keys, tagline_keys)
    tagline_keys.each do |k|
      reject_title_keys_cases(d_store, d_keys, k, d_store[k]['field_name'], tagline_keys)
    end
    puts "tagline_keys: #{tagline_keys}"
    tagline_keys
  end

  def reject_title_keys_cases(d_store, d_keys, k, field_name)
    case k
      when 'medium' && field_name.split(' ').include?('giclee') && d_store['material']['field_name'].split(' ').exclude?('paper'); true #tagline_keys.delete(k)
      when 'material' && field_name.split(' ').include?('paper'); true #tagline_keys.delete(k)
      when 'title' && field_name[0] != "\""; true #tagline_keys.delete(k)
      else false
    end
  end


  # def title_keys(d_hsh, d_keys)
  #   reorder_title_keys(d_hsh, all_title_keys).reject {|k| reject_title_keys(d_hsh, d_keys, k)}
  # end

  # def reorder_title_keys(d_hsh, title_keys)
  #   all_title_keys.each do |k|
  #     reorder_title_key_cases(k, d_hsh[k]['field_name'], title_keys) if d_hsh.has_key?(k)
  #   end
  #   title_keys
  # end
  #
  # def reorder_title_key_cases(k, v, title_keys)
  #   if k == 'numbering' && v.split(' ')[0] == 'from'
  #     title_keys.delete(k)
  #     title_keys.insert(title_keys.index('material'), k)
  #   else
  #     title_keys
  #   end
  # end

  # def reject_title_keys(d_hsh, d_keys, k)
  #   return true if d_keys.exclude?(k)
  #   reject_title_keys_cases(d_hsh, d_keys, k, d_hsh[k]['field_name'])
  # end

  # def reject_title_keys_cases(d_hsh, d_keys, k, v)
  #   case
  #     when k == 'medium' && v.split(' ').include?('giclee') && d_hsh['material']['field_name'].split(' ').exclude?('paper'); true
  #     when k == 'material' && v.split(' ').include?('paper'); true
  #     when k == 'title' && v[0] != "\""; true
  #     #when k == 'title' && v.blank?; true
  #     else false
  #   end
  # end

  def export_keys
    %w[sku artist tag_line medium material width]
  end

  def all_title_keys
    %w[artist title mounting embellished category sub_category medium material dimension leafing remarque numbering signature certificate]
  end

  # body_keys ##################################################################

  def body_keys(d_hsh, d_keys)
    reorder_title_keys(d_hsh, all_body_keys).reject {|k| reject_body_keys(d_hsh, d_keys, k)}
  end

  def reject_body_keys(d_hsh, d_keys, k)
    d_keys.exclude?(k)
  end

  def all_body_keys
    %w[title embellished category sub_category medium material leafing remarque artist numbering signature mounting certificate dimension]
  end

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
  def csv_hsh(pg_hsh, i_tags, p_tags, csv_hsh={})
    pg_hsh = {'mounting' => pg_hsh['field_sets']['mounting']['mounting_id'].try(:field_name), 'medium'=> pg_hsh['options']['medium_id'].try(:field_name)}
    csv_hsh.merge!(csv_media(p_tags, pg_hsh['medium']))
    csv_hsh.merge!(csv_dimensions(i_tags, pg_hsh['mounting']))
    csv_hsh
  end

  # csv dimensions ###################################################

  def csv_dimensions(i_tags, mounting_val)
    dimension_keys.map {|k| format_csv_dimension_hsh(k.split('_'), i_tags.try(:[], k), mounting_val)}.to_h
  end

  def format_csv_dimension_hsh(split_key, val, mounting_val)
    kind, dimension = split_key
    [csv_dimension_key(dimension, kind), csv_dimension_val(kind, val, mounting_val)]
  end

  def csv_dimension_key(dimension, kind)
    kind == 'material' ? dimension : ['frame', dimension].join('_')
  end

  def csv_dimension_val(kind, val, mounting_val)
    return if val.nil?
    kind == 'material' ? val.to_i : frame_dimensions(val, mounting_val)
  end

  def frame_dimensions(val, mounting_val)
    val.to_i if val && mounting_val == 'framing'
  end

  def dimension_keys
    %w[material_width material_height mounting_width mounting_height]
  end

  def media_keys
    %w[category medium material]
  end

  # update THIS ################################################################

  def csv_media(p_tags, medium_val, csv_hsh={})
    media_keys.each do |k|
      csv_hsh.merge!(media_case(k, p_tags[k], medium_val))
    end
    csv_hsh
  end

  def media_case(k, v, medium_val)
    if k == 'category'
      [%w[art_type, art_category], category_case(v)].transpose.to_h
    elsif k == 'medium'
      {k => medium_case(v, medium_val)}
    elsif k == 'material'
      {k => material_case(v.underscore.split('_'))}
    end
  end

  def category_case(v)
    if ['Original', 'OneOfAKind'].include?(v)
      ['Original', 'Original Painting']
    elsif v == 'LimitedEdition'
      ['Limited Edition', 'Limited Edition']
    elsif v == 'PrintMedia'
      ['Print', 'Limited Edition']
    end
  end

  def material_case(material_split)
    case
      when material_split.include?('canvas'); 'Canvas'
      when material_split.include?('paper'); 'Paper'
      when material_split.include?('wood') || material_split.include?('acrylic'); 'Board'
      when material_split.include?('metal'); 'Metal'
      when material_split.include?('sericel'); 'Sericel'
    end
  end

  def medium_case(medium, medium_val)
    if medium = %w[painting drawing].detect {|k| medium.underscore.split('_').include?(k)}
      return 'Unknown' if medium_val.blank? || medium_val == 'painting'
      public_send(medium+'_option_case', medium_val.split(' ')[0])
    else
      medium_option_case(medium)
    end
  end

  def medium_option_case(medium)
    case
      when ['BasicMixedMedia', 'AcrylicMixedMedia', 'Relief'].include?(medium); 'Mixed Media'
      when ['Etching', 'Giclee', 'Lithograph', 'Monoprint', 'Poster'].include?(medium); medium
      when medium == 'Silkscreen'; 'Serigraph'
    end
  end

  def painting_option_case(medium)
    case
      when %w[oil acrylic watercolor pastel guache].include?(medium); medium.capitalize
      when medium == 'mixed'; 'Mixed Media'
      when medium == 'sumi-ink'; 'Watercolor'
    end
  end

  ####################################################

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
