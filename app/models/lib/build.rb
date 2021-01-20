module Build
  # [medium_category medium material]
  # def seed_products(store: seed_fields)
  #   constants.each do |prd| #Painting
  #     modulize(self,kind).opts.each do |key, key_set|
  #     end
  #   end
  # end

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

  def field_groups(store)
    [FGS, FGO].each do |k|
      k.constants.each do |kind|
        modulize(k,kind).opts.each do |key, key_group|
          targets = merge_targets(key_group, store)
          params_merge(params: store, dig_set: dig_set(key, targets, k.name.to_sym, kind))
        end
      end
    end
    store
  end

  ##############################################################################

  def seed_products(store: seed_fields, products: [])
    constants.each do |type| #Painting
      modulize(self, type).opts.each do |subtype, field_group| # StandardPainting, field_group
        p_hsh = build_kg(field_group[:key_group], store)
        build_fgo(p_hsh, field_group.dig(:FGO), store, products)
        build_fgs(field_group.dig(:FGS), store, products)
      end
    end
    products
  end

  def build_kg(key_group, store, p={})
    key_group.each do |keys| #[:RadioButton, :Category, :Original]
      p[keys[1]] = store.dig(*keys) # {:Category => <RadioButton>}
    end
    p
  end

  def build_fgo(p_hsh, key_group, store, products)
    return products << p_hsh if !key_group
    key_group.each do |key_set|

      modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
        p = p_hsh.dup
        p[keys[1]] = store.dig(*keys)
        products << p
      end

    end
    products
  end

  def build_fgs(key_group, store, products)
    return products if !key_group
    key_group.each do |key_set|
      modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
        products.map{|p| p[keys[1]] = store.dig(*keys)}
      end
    end
    products
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

  def merge_targets(key_group, store, targets=[])
    key_group.each do |key_set|
      targets << store.dig(*key_set)
    end
    targets.compact.flatten
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
