require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    h = i.input_group   h = Item.find(97).input_group

  def input_group(f_grp={p_hsh:{}, rows:[], d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    p_hsh_params(f_grp, product.tags.slice('product_type'))
    f_grp = product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
    related_params(f_grp[:d_hsh], f_grp[:store], f_grp[:attrs])
    f_grp
    #d_hsh_params(f_grp)
    # attr_params(f_grp)
  end

  def p_hsh_params(f_grp, product_type)
    f_grp[:p_hsh].merge!({'product_category'=>product_category(product_type), 'product_type'=> product_type})
  end

  def input_params
    self.tags.each_with_object({}) do |(tag_key, tag_val), h|
      if tag_assoc_keys = tag_assoc_keys(tag_key)
        k, t, f_name = tag_assoc_keys
        Item.case_merge(h, input_val(t, tag_val), k, t, f_name)
      end
    end
  end

  def d_hsh_params(f_grp)
    store = d_hsh_loop(f_grp[:d_hsh], f_grp[:store])
    #i_group[:attrs]
  end

  ###############################################################
  #material, mounting, dimension
  ###############################################################

  def related_params(d_hsh, store, attrs)
    merge_related_params('material', 'mounting', 'material_mounting', 'body', d_hsh, store)
    merge_related_params('mounting', 'dimension', 'mounting_dimension', 'mounting_dimension', d_hsh, store)
    dimension_params('dimension', 'material_dimension', 'mounting_dimension', d_hsh, store, attrs)
  end

  def merge_related_params(k_key, k_key2, sub_key, end_key, d_hsh, store)
    if k_hsh = d_hsh[k_key]
      sub_hsh = k_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.slice!(*tb_keys)
      store[k_key] = k_hsh
      Item.case_merge(d_hsh, sub_hsh[sub_key], k_key2, sub_key, end_key) if sub_hsh[sub_key]
      d_hsh.delete(k_key)
    end
  end

  def dimension_params(k_key, sub_key, sub_key2, d_hsh, store, attrs, hsh={})
    if k_hsh = d_hsh[k_key]
      sub_hsh = k_hsh.slice!(sub_key)
      dim_keys, dim_tag = k_hsh[sub_key].keys[0].underscore.split('_'), k_hsh[sub_key].values.reject{|v| v=='n/a'}[0]

      material_dimension_params(sub_hsh, sub_key, dim_keys, dim_tag, d_hsh, attrs, hsh)
      mounting_dimension_params(sub_hsh, sub_key2, attrs, hsh)

      body_dimensions(k_key, sub_key, sub_key2, hsh, store) if hsh.any?
      tagline_dimensions(hsh, k_key, sub_key, sub_key2, store) if hsh.any?
    end
  end

  # material_dimension_params ##################################################
  def material_dimension_params(sub_hsh, sub_key, dim_keys, dim_tag, d_hsh, attrs, hsh)
    if vals_exist?(sub_hsh, dim_keys)
      dim_hsh = sub_hsh.slice(*dim_keys)
      format_material_dimensions(dim_hsh.values, dim_hsh.values[0..1], dim_keys[0], dim_tag, attrs, hsh, sub_key)
    else
      attrs.merge!(attrs_dimension_params([nil]))
    end
    dim_keys.map{|k| sub_hsh.delete(k)}
  end

  def format_material_dimensions(dims, dim_set, dim_type, dim_tag, attrs, h, sub_key)
    attrs.merge!(attrs_dimension_params(dim_set))
    h.merge!({sub_key=>material_dimension(dims, dim_set, dim_type, dim_tag)})
  end

  def material_dimension(dims, dim_set, dim_type, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, dim_type), 'tag'=> dim_tag}
  end

  # mounting_dimension_params ##################################################
  def mounting_dimension_params(sub_hsh, sub_key, attrs, hsh)
    if sub_hsh.has_key?(sub_key)
      dim_hsh = sub_hsh.slice!(sub_key) #dim_tag = sub_hsh.values[0]
      dim_tag, framed = sub_hsh[sub_key].values[0], (sub_hsh.values[0]=='(frame)')
      format_mounting_dimensions(dim_hsh, sub_key, dim_tag, framed, attrs, hsh)
    else
      attrs.merge!(attrs_dimension_params([nil], keys: %w[frame_width frame_height]))
    end
  end

  def format_mounting_dimensions(dim_hsh, sub_key, dim_tag, framed, attrs, h)
    if vals_exist?(dim_hsh, dim_hsh.keys) && dim_tag
      attr_dims = framed ? dim_hsh.values[0..1] : [nil]
      attrs.merge!(attrs_dimension_params(attr_dims, keys: %w[frame_width frame_height]))
      h.merge!({sub_key=> mounting_dimension(dim_hsh.values, dim_hsh.values[0..1], dim_tag)})
    end
  end

  def mounting_dimension(dims, dim_set, dim_tag)
    {'measurements'=> measurements(dims), 'item_size'=> item_size(dim_set, 'mounting'), 'tag'=> dim_tag}
  end

  #shared methods ##############################################################
  def measurements(d_names)
    d_names.map{|i| i+"\""}.join(' x ')
  end

  def item_size(dims, dim_name=nil)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end

  def tagline_dimensions(hsh, k_key, sub_key, sub_key2, store)
    key = [sub_key2, sub_key].detect{|key| hsh.has_key?(key)}
    Item.case_merge(store, "(#{hsh.dig(key,'measurements')})", k_key, 'tagline') if hsh.dig(key, 'item_size') >= 1300
  end

  def body_dimensions(k_key, sub_key, sub_key2, hsh, store)
    if h = hsh.dig(sub_key)
      str = [h['measurements'], h.dig('tag')].compact.join(' ')+'.'
      str = [hsh[sub_key2]['measurements'], hsh[sub_key2]['tag']].join(' ')+', '+str if hsh.has_key?(sub_key2)
      Item.case_merge(store, "Measures approx. #{str}", k_key, 'body')
    end
  end

  # attrs_dimension_params #####################################################
  def attrs_dimension_params(dim_set, keys: ['width', 'height'])
    [keys, [dim_set[0], dim_set[-1]]].transpose.to_h
  end

  ###############################################################
  ###############################################################



  def attr_params(f_grp)
    item_attrs(f_grp)
    artist_params(f_grp)
    title_params(f_grp)
    f_grp
  end

  # input_params ###############################################################
  def input_val(t, tag_val)
    tag_attr?(t) ? tag_val : detect_input_val(t, tag_val.to_i)
  end

  def detect_input_val(t, id)
    fieldables.detect{|f| attr_match?(f, t, id)}
  end

  def attr_match?(f, t, id)
    f.id == id && f.type.underscore == t
  end

  def tag_assoc_keys(tag_key)
    tag_key.split('::') if tag_key.index('::')
  end

  # d_hsh_params ###############################################################
  def d_hsh_loop(d_hsh, store, tag_keys=%w[tagline body])
    d_hsh.each_with_object(store) do |(k, tb_hsh), store|
      k_hsh = tb_hsh.slice!(*tag_keys)
      tb_hsh.any? ? tb_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.to_a : tb_hsh
      description_case(k, tb_hsh, k_hsh, store)
    end
  end

  def description_case(k, tb_set, k_hsh, store)
    case k
      when 'numbering'; numbering_case(k, tb_set, k_hsh, store)
      #when 'dimension'; dimension_case(k_hsh, k, 'material_dimension', 'mounting_dimension', store)
      #when 'mounting'; mounting_case(k, tb_set, k_hsh, 'mounting_dimension', store)
      #when 'material'; material_case(k, tb_set, k_hsh, 'material_mounting', store)
      when 'dated'; dated_case(k, tb_set, k_hsh, store)
      when 'verification'; verification_case(k, tb_set, k_hsh, store)
      when 'disclaimer'; disclaimer_case(k, tb_set, k_hsh, store)
      else tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
    end
  end
  
  # numbering ##################################################################
  def numbering_case(k, tb_set, k_hsh, store)
    ed_val = edition_value(k_hsh)
    tb_set.each_with_object(store) do |set,store|
      Item.case_merge(store, [set[1], ed_val].compact.join(' '), k, set[0])
    end
  end

  def edition_value(k_hsh)
    if k_hsh.keys.count == 2
      k_hsh.values.join('/')
    elsif k_hsh.keys.include?('edition_size')
      "out of #{k_hsh['edition_size']}"
    end
  end

  # refactored above ###########################################################
  def validated_slice(h, keys, test: :all?)
    h.slice!(*keys) if valid_slice?(h, keys, test)
  end

  def valid_slice?(h, keys, check)
    keys.public_send(check){|k| h[k].present?}
  end

  def vals_exist?(h, keys, check: :all?)
    keys.public_send(check){|k| h[k].present?}
  end

  # dated ######################################################################
  def dated_case(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.map{|set| Item.case_merge(store, [set[1], "(#{k_hsh.values[0]})"].join(' '), k, set[0])}
  end

  # verification ###############################################################
  def verification_case(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.map{|set| Item.case_merge(store, [set[1], "#{k_hsh.values[0]}"].join(' '), k, set[0])}
  end

  # disclaimer #################################################################
  def disclaimer_case(k, tb_set, k_hsh, store)
    return if tb_set.none? && k_hsh.none?
    tb_set.each do |set|
      v = set[0] == 'body' ? disclaimer(set[1], k_hsh.values[0]) : set[1]
      Item.case_merge(store, v, k, set[0])
    end
  end

  def disclaimer(severity, damage)
    case severity
      when 'danger'; "** Please note: #{damage}. **"
      when 'warning'; "Please note: #{damage}."
      when 'notation'; damage
    end
  end



  def tagline_keys
    %w[artist title mounting embellishing category edition_type medium material dimension leafing remarque numbering signature certificate disclaimer]
  end

  def body_keys
    %w[title text_before_coa embellishing category edition_type medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting seal certificate dimension disclaimer]
  end

  # attr_params ################################################################
  def item_attrs(f_grp)
    %w[sku retail qty].map{|k| f_grp[:attrs].merge!({k=> public_send(k)})}
    f_grp[:attrs].merge!(product.tags.select{|k,v| Medium.item_tags.include?(k.to_sym)})
  end

  def artist_params(f_grp)
    return unless artist
    f_grp[:store].merge!({'artist'=> artist.artist_params['d_hsh']})
    f_grp[:attrs].merge!(artist.artist_params['attrs'])
  end

  def title_params(f_grp)
    if f_grp[:p_hsh]['product_category'] == 'GartnerBlade' #if f_grp.dig(:attrs, 'artist') == 'GartnerBlade'
      gartner_blade_title(f_grp, Sculpture.input_group.last)
    else
      f_grp[:store].merge!({'title'=> {'tagline'=> tagline_title, 'body'=> body_title}})
      f_grp[:attrs].merge!({'title'=> attrs_title})
    end
  end

  def tagline_title
    "\"#{self.title}\"" unless self.title.blank?
  end

  def body_title
    tagline_title ? tagline_title : 'This'
  end

  def attrs_title
    tagline_title ? tagline_title : 'Untitled'
  end

  def gartner_blade_title(f_grp, title_keys)
    title_val = title_keys.map{|k| f_grp[:d_hsh][k]['tagline']}.reject{|i| i.blank?}
    #f_grp[:d_hsh].select!{|k,v| title_keys.exclude?(k)}
    if title_val.any?
      title = "\"#{title_val.join(' ')}\""
      f_grp[:store].merge!({'title'=> {'tagline'=> title, 'body'=> title}})
      f_grp[:attrs].merge!({'title'=> title})
    end
  end

  def tb_keys
    %w[tagline body]
  end

end

# THE END ######################################################################
# def mounting_dimension_tag(kind, kind2, k, k2, top_key, f_grp)
#   if tag = f_grp.dig(top_key, kind, k, k2)
#     Item.case_merge(f_grp, tag, top_key, kind2, k, k2)
#   end
# end

#refactor + refactor material to accomodate gallery wrapped
# def material_case(k, tb_set, k_hsh, key, store)
#   tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
#   Item.case_merge(store, k_hsh[key].values[0], 'mounting', 'body') if k_hsh[key] # 'mounting', 'body'
# end
#
# def mounting_case(k, tb_set, k_hsh, key, store)
#   tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
#   Item.case_merge(store, k_hsh[key].values[0], k, key) if k_hsh[key]
# end

# def oversized?(d_hsh, k='dimension', key='material_dimension', key2='mounting_dimension')
#   d_key = d_hsh.dig(k, key2, 'item_size') ? key2 : key
#   d_hsh.dig(k, d_key, 'item_size') >= 1300
# end

# def dimension_case(k_hsh, k, key, key2, store)
#   hsh = k_hsh.slice!(key)
#   puts "hsh: #{hsh}, k_hsh: #{k_hsh}"
#   if h = material_and_mounting_dimensions(hsh, key, key2, k_hsh[key].keys[0].underscore.split('_'), k_hsh[key].values[0])
#     store[k] = h
#   end
# end

# def material_and_mounting_dimensions(hsh, key, key2, f_keys, dim_tag)
#   if valid_dimensions?(hsh, f_keys)
#     material_hsh = material_dimension(hsh, f_keys, dim_tag, key)
#     mounting_dimension(hsh, material_hsh, key2, %w[mounting_width mounting_height])
#   end
# end
#
# def material_dimension(dimension_hsh, f_keys, dim_tag, key)
#   dim_keys, dim_vals = f_keys.map{|f_key| [f_key, dimension_hsh[f_key]]}.transpose
#   dim_type, dim_tag = dim_keys[0], (dim_tag == 'n/a' ? nil : dim_tag)
#   {key=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size(dim_type, dim_vals[0..1]), 'width'=> dim_vals[0..1][0], 'height'=> dim_vals[0..1][-1], 'tag'=> dim_tag}}
# end
#
# def mounting_dimension(hsh, material_hsh, key2, f_keys)
#   return material_hsh unless valid_dimensions?(hsh, f_keys)
#   dim_vals, dim_tag = f_keys.map{|f_key| hsh[f_key]}, (hsh[key2] == 'n/a' ? nil : hsh[key2])
#   material_hsh.merge!({key2=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size('mounting', dim_vals[0..1]), 'frame_width'=> dim_vals[0..1][0], 'frame_height'=> dim_vals[0..1][-1], 'tag'=> dim_tag}})
# end
#
# def dimension_vals(dimension_hsh, dimension_keys)
#   dimension_keys.map{|k| dimension_keys[k]} if valid_dimensions?(dimension_hsh, dimension_keys)
# end
#
# def valid_dimensions?(dimension_hsh, dimension_keys)
#   dimension_keys.all?{|k| dimension_hsh[k].present?}
# end

# def dimension_case(k_hsh, k, key, key2, store)
#   dimension_hsh = k_hsh.slice!(key)
#   f_name, dim_tag = k_hsh[key].to_a.flatten
#   material_and_mounting_dimensions(dimension_hsh, k, key, key2, f_name.underscore.split('_'), dim_tag, store)
# end

# def material_and_mounting_dimensions(dimension_hsh, k, key, key2, f_keys, dim_tag, store)
#   if valid_dimensions?(dimension_hsh, f_keys)
#     material_hsh = material_dimension(dimension_hsh, f_keys, dim_tag, k, key)
#     store[k] = mounting_dimension(dimension_hsh, material_hsh, f_keys, key2)
#   end
# end

# def mounting_dimension(dimension_hsh, material_hsh, f_keys, key2)
#   mounting_hsh = dimension_hsh.select{|f_key| f_keys.exclude?(f_key)}
#   return material_hsh unless mounting_hsh && mounting_hsh.values.count >= 2
#   dim_vals = mounting_hsh.values
#   material_hsh.merge!({key2=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size('mounting', dim_vals[0..1]), 'frame_width'=> dim_vals[0..1][0], 'frame_height'=> dim_vals[0..1][-1]}})
# end

# dimension2 #################################################################
# mounting_dimension_tag('mounting', 'dimension', 'mounting_dimension', 'tag', d_hsh)
# def mounting_dimension_tag(kind, kind2, k, k2, store)
#   if tag = store.dig(kind, k, k2)
#     Item.case_merge(store, tag, kind2, k, k2)
#   end
# end

# def mounting_dimension_tag(kind, kind2, k, k2, top_key, f_grp)
#   if tag = f_grp.dig(top_key, kind, k, k2)
#     Item.case_merge(f_grp, tag, top_key, kind2, k, k2)
#   end
# end
