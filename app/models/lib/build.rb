module Build
  # a = PRD.seed_products
  def seed_products(store: seed_fields, products: [])
    constants.each do |type| #Painting
      modulize(self, type).opts.each do |subtype, field_group| # StandardPainting, field_group
        p_hsh = {'p'=>{}, 'tags'=>{'product_type'=> type, 'product_subtype'=> subtype}}
        build_product_group(field_group, store, p_hsh, products)
      end
    end
    products
  end

  def build_product_group(field_group, store, p_hsh, products)
    p_hsh = build_kg(field_group.dig(:key_group), store, p_hsh)
    p_hsh = build_fgs(field_group.dig(:FGS), store, p_hsh)
    build_fgo(field_group.dig(:FGO), store, p_hsh, products)
    products
  end

  def build_kg(key_group, store, p_hsh)
    return p_hsh if !key_group
    key_group.each do |keys| #[:RadioButton, :Category, :Original]
      p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
      build_tags(p_hsh, keys[1])
    end
    p_hsh
  end

  def build_fgs(key_group, store, p_hsh)
    return p_hsh if !key_group
    key_group.each do |key_set|
      modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
        p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
        build_tags(p_hsh, keys[1])
      end
    end
    p_hsh
  end

  def build_fgo(key_group, store, p_hsh, products, set=[])
    return products << p_hsh if !key_group
    kind_groups = key_group.map{|keys| modulize(keys[0], keys[1]).opts[keys[2]]}.flatten(1)
    kind_groups.map{|key_set| set << store.dig(*key_set)}
    kind_sets = set.group_by(&:kind).values
    combined_fields = kind_sets[0].product(*kind_sets[1..-1]).map{|a| a.group_by(&:kind).transform_values{|v| v[0]}.transform_keys{|k| k.to_sym}}
    
    combined_fields.each do |f_hsh|
      p = p_hsh.dup
      p['p'].merge!(f_hsh)
      f_hsh.keys.each {|k| build_tags(p, k)}
      products << p
    end

    # puts "__"
    # #puts "kind_sets[0]: #{kind_sets[0]}, kind_sets[1..-1]: #{kind_sets[1..-1]}"
    # puts "product: #{kind_sets[0].product(*kind_sets[1..-1]).map{|a| a.group_by(&:kind)}}"
    # puts "__"
    # key_group.each do |key_set|
    #   modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
    #     p = p_hsh.dup
    #     p['p'].merge!({keys[1] => store.dig(*keys)})
    #
    #     build_tags(p, keys[1])
    #     products << p
    #
    #   end
    # end
    products
  end

  def build_tags(p_hsh, kind)
    if [:Category, :Medium, :Material].include?(kind)
      p_hsh['tags'].merge!({kind => p_hsh['p'][kind].field_name})
    end
  end

  ##############################################################################

  def order_fields(p_hsh, p={})
    field_order.each do |k|
      p[k] = p_hsh[k] if p_hsh.has_key?(k)
    end
    p
  end

  def set_tags(p, tags={})
    [:Category, :Medium, :Material].each do |k|
      tags[k.to_s.downcase] = p[k]
    end
    tags
  end

  def field_order
    [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate]
  end

  ##############################################################################

  def seed_fields
    seed_field_assocs(store: seed_options)
  end

  def seed_options(store:{})
    [OPT, NF, TF, TFA].each do |k|
      k.cascade_build(store: store)
    end
    store
  end

  def seed_field_assocs(store:{})
    [RBTN, SFO, FSO, SMO].each do |k|
      k.cascade_assoc(store: store)
    end
    store
  end

  ##############################################################################

  def cascade_build(store:{})
    constants.each do |kind|
      modulize(self,kind).opts.each do |key, key_set|
        opt_set = key_set.map{|opt| context_build(fieldable: field_class, field_name: opt, kind: kind)}
        params_merge(params: store, dig_set: dig_set(key, opt_set, field_type.to_sym, kind))
      end
    end
    store
  end

  def cascade_assoc(store:{})
    constants.each do |kind|
      modulize(self,kind).opts.each do |key, key_group|
        build_and_merge(field_class, key, kind, build_targets(key_group, store), store)
      end
    end
    store
  end

  def build_and_merge(fieldable, field_name, kind, targets, store)
    field = context_build(fieldable: fieldable, field_name: field_name, kind: kind, targets: targets)
    puts "#{params_merge(params: store, dig_set: dig_set(field_name, field, field.type.to_sym, kind))}"
  end

  def build_targets(key_group, store, targets=[])
    key_group.each do |key_set|
      targets << build_target(key_set, store)
    end
    targets.compact.flatten
  end

  def build_target(key_set, store)
    if !store.dig(*key_set)
      cascade_build_target(key_set[0], key_set[1], key_set[2], store)
    else
      store.dig(*key_set)
    end
  end

  def cascade_build_target(type, kind, key, store)
    key_group = modulize(module_name(type), kind).opts[key]
    build_and_merge(modulize(type), key, kind, build_targets(key_group, store), store)
  end

  ##############################################################################

  def context_build(fieldable:, field_name:, kind:, tags:nil, targets:[])
    field = fieldable.where(field_name: field_name, kind: kind, tags: tags).first_or_create
    targets.map{|target| field.assoc_unless_included(target)}
    field
  end

  def field_class
    field_type.constantize
  end

  def field_module(key)
    module_name(key).constantize
  end

  def field_type
    field_hsh[name]
  end

  def modulize(*keys)
    keys.map{|k| k.to_s}.join('::').constantize
  end

  def module_name(key)
    field_hsh.invert[key.to_s].to_sym
  end

  def field_hsh
    {'OPT' => 'Option', 'RBTN' => 'RadioButton', 'FSO' => 'FieldSet', 'SFO' => 'SelectField', 'SMO' => 'SelectMenu', 'NF' => 'NumberField', 'TF' => 'TextField', 'TFA' => 'TextAreaField'}
  end

  ##############################################################################

  def params_merge(params:, dig_set:, keys:[])
    dig_keys, dig_values = dig_set[0], dig_set[1]
    dig_keys.each_with_index do |k, i|
      if !params.dig(*keys.append(k))
        if params.has_key?(dig_keys[0])
          keys[0..i-1].inject(params, :fetch)[k] = dig_values[i]
        else
          params[k] = dig_values[i]
        end
      end
    end
    params
  end

  def dig_set(k, v, *keys)
    keys.map{|key| [key, {}]}.append([k,v]).transpose
  end

  def build_key_group(set, field_type, kind)
    set.map{|key| [field_type, kind, key]}
  end

end


# def build_fgo(key_group, store, p_hsh, products, set=[])
#   return products << p_hsh if !key_group
#   # kind_groups = key_group.map{|keys| modulize(keys[0], keys[1]).opts[keys[2]]}.flatten(1)
#   # kind_groups.map{|key_set| set << store.dig(*key_set)}
#   # puts "__"
#   # puts "kind_groups: #{kind_groups}"
#   # puts "kind_groups: #{set}"
#   # #puts "kind_groups: #{set.group_by(&:kind)}"
#   # puts "__"
#   key_group.each do |key_set|
#     modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
#       p = p_hsh.dup
#       p['p'].merge!({keys[1] => store.dig(*keys)})
#
#       build_tags(p, keys[1])
#       products << p
#
#     end
#   end
#   products
# end

# def field_groups(store)
#   [FGS, FGO].each do |k|
#     k.constants.each do |kind|
#       modulize(k,kind).opts.each do |key, key_group|
#         targets = merge_targets(key_group, store)
#         params_merge(params: store, dig_set: dig_set(key, targets, k.name.to_sym, kind))
#       end
#     end
#   end
#   store
# end


# def merge_targets(key_group, store, targets=[])
#   key_group.each do |key_set|
#     targets << store.dig(*key_set)
#   end
#   targets.compact.flatten
# end
