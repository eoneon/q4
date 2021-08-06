require 'active_support/concern'

module ItemProduct
  extend ActiveSupport::Concern
  # i = Item.find(97)    h = i.input_group   h = Item.find(97).input_group

  def input_group(f_grp={p_hsh:{}, rows:[], d_hsh:{}, attrs:{}, store:{}})
    return f_grp if !product
    p_hsh_params(f_grp, product.tags.slice('product_type'))
    f_grp = product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
    d_hsh_params(f_grp)
    attr_params(f_grp)
  end

  def input_params
    self.tags.each_with_object({}) do |(tag_key, tag_val), h|
      if tag_assoc_keys = tag_assoc_keys(tag_key)
        k, t, f_name = tag_assoc_keys
        Item.case_merge(h, input_val(t, tag_val), k, t, f_name)
      end
    end
  end

  def p_hsh_params(f_grp, product_type)
    f_grp[:p_hsh].merge!({'product_category'=>product_category(product_type), 'product_type'=> product_type})
  end

  def d_hsh_params(f_grp)
    d_hsh = d_hsh_loop(f_grp[:d_hsh], f_grp[:store])
    #i_group[:attrs]
  end

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
      when 'dimension'; dimension_case(k_hsh, k, 'material_dimension', 'mounting_dimension', store)
      when 'mounting'; mounting_case(k, tb_set, k_hsh, 'mounting_dimension', store)
      when 'material'; material_case(k, tb_set, k_hsh, 'material_mounting', store)
      when 'dated'; dated_case(k, tb_set, k_hsh, store)
      when 'verification'; verification_case(k, tb_set, k_hsh, store)
      when 'disclaimer'; disclaimer_case(k, tb_set, k_hsh, store)
      else tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
    end
  end

  #refactor + refactor material to accomodate gallery wrapped
  def material_case(k, tb_set, k_hsh, key, store)
    tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
    Item.case_merge(store, k_hsh[key].values[0], k, key) if k_hsh[key]
  end

  def mounting_case(k, tb_set, k_hsh, key, store)
    tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
    Item.case_merge(store, k_hsh[key].values[0], k, key) if k_hsh[key]
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

  # dimension ##################################################################
  def dimension_case(k_hsh, k, key, key2, store)
    dimension_hsh = k_hsh.slice!(key)
    f_name, dim_tag = k_hsh[key].to_a.flatten
    if material_hsh = valid_material_hsh?(dimension_hsh.slice!(*f_name.underscore.split('_')))
      h = material_dimension(dim_tag, material_hsh.keys[0], material_hsh.values, key)
      store[k] = h.merge!(mounting_dimension(dimension_hsh, key2))
    end
  end

  def valid_material_hsh?(material_hsh)
    material_hsh if material_hsh.any? && (material_hsh.keys.count >= 2) || (material_hsh.keys.count == 1 && material_hsh.keys[0] == 'diameter')
  end

  def material_dimension(dim_tag, dim_type, dim_vals, key)
    {key=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size(dim_type, dim_vals[0..1]), 'width'=> dim_vals[0..1][0], 'height'=> dim_vals[0..1][-1], 'tag'=> (dim_tag == 'n/a' ? nil : dim_tag)}}
  end

  def mounting_dimension(mounting_hsh, key2)
    return {} unless mounting_hsh && mounting_hsh.values.count > 1
    dim_vals = mounting_hsh.values
    {key2=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size('mounting', dim_vals[0..1]), 'frame_width'=> dim_vals[0..1][0], 'frame_height'=> dim_vals[0..1][-1]}}
  end

  def item_size(dim_name, dims)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end

  def measurements(d_names)
    d_names.map{|i| i+"\""}.join(' x ')
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

  def oversized?(d_hsh, k='dimension', key='material_dimension', key2='mounting_dimension')
    d_key = d_hsh.dig(k, key2, 'item_size') ? key2 : key
    d_hsh.dig(k, d_key, 'item_size') >= 1300
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
    f_grp[:store].merge!({'artist'=> artist.artist_params['d_hsh']}) if artist
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

end

# THE END ######################################################################
# def input_group(f_grp={rows:[], p_hsh:{}, d_hsh:{}, attrs:{}, store:{}})
#   return f_grp if !product
#   p_hsh_params(f_grp, product.tags.slice('product_type'))
#   f_grp = product.d_hsh_and_row_params(grouped_hsh(enum: product.fieldables), input_params, f_grp)
#   #f_grp = product.input_build(grouped_hsh(enum: product.fieldables), input_params, f_grp)
#   #f_grp.merge!({rows: assign_row(f_grp[:rows].group_by{|h| h[:k]})})
#   attr_params(f_grp)
# end

# def assign_row(f_grp)
#   kinds.each_with_object([]) do |form_row, rows|
#     row = form_row.select{|col| f_grp.has_key?(col)}
#     rows.append(row.map!{|col| f_grp[col]}.flatten!) if row.any?
#   end
# end
################################################################################
# DRAFT/REPLACED METHODS #######################################################

# relevant lines: v_hsh.transform_values!{|v| v[0]}, h[k] = v_hsh.one? ? v_hsh.values[0] : v_hsh
# def format_d_hsh(d_hsh)
#   d_hsh.each_with_object({}) do |(k,v_hsh),h|
#     v_hsh.transform_values!{|v| v[0]}
#     h[k] = v_hsh.one? ? v_hsh.values[0] : v_hsh
#   end
# end
