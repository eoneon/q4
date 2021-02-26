module Build
  # a = PRD.seed_product_type
  # a.map{|h| {name: h['name'], tags: h['tags']}}
  # a = Build.seed_products
  def self.seed_products(store: PRD.seed_fields, products: [])
    [PRD, GBPRD, APRD].each do |prd|
      prd.seed_product_type(store: store)
    end
  end

  ##############################################################################

  def seed_product_type(store: seed_fields, products: [])
    constants.each do |type| #Painting
      module_cascade(type, store, products)
    end
    format_products(products)
  end

  def module_cascade(type, store, products)
    modulize(self, type).opts.each do |subtype, field_group| # StandardPainting, field_group
      p_hsh = {'p'=>{}, 'tags'=>{'product_type'=> type.to_s, 'product_subtype'=> subtype.to_s}}
      products = build_product_group(field_group, store, p_hsh, products)
    end
    products
  end

  def format_products(products)
    products.each do |p_hsh|
      format_product(p_hsh['p'], p_hsh['tags'])
    end
  end

  ##############################################################################

  def format_product(p, tags, product={})
    product['p'] = sort_fields(p)
    product['tags'] = build_tags(p, tags)
    product['name'] = build_name(product['tags'])
    Product.builder({product_name: product['name'], options: product['p'], tags: product['tags']})
  end

  def sort_fields(p, p_set=[])
    field_order.each do |k|
      p_set << p[k] if p.has_key?(k)
    end
    p_set
  end

  def field_order
    [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate]
  end

  def build_name(tags, name_set=[])
    name_keys.each do |k|
      next if !tags.dig(k)
      name = tags[k].underscore.split('_').map{|word| word.capitalize}.join(' ')
      name = k == 'material' ? "on #{name}" : name
      name_set << name
    end
    format_name(name_set.join(' '))
  end

  def build_tags(p, tags)
    tag_keys.each do |k|
      next if !p.has_key?(k)
      tags[k.to_s.underscore] = p[k].field_name
    end
    tags
  end

  def format_name(name)
    [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['One Of One', 'One-of-One']].each do |word_set|
      name.sub!(word_set[0], word_set[1])
    end
    name.split(' ').map(&:strip).join(' ')
  end

  def name_keys
    tag_keys.map{|k| k.to_s.underscore}
  end

  def tag_keys
    [:Category, :Medium, :Material]
  end

  ##############################################################################

  def build_product_group(field_group, store, p_hsh, products)
    build_kg(field_group.dig(:key_group), store, p_hsh)
    build_fgs(field_group.dig(:FGS), store, p_hsh)
    build_fgo(field_group.dig(:FGO), store, p_hsh, products)
  end

  def build_kg(key_group, store, p_hsh)
    return p_hsh if !key_group
    key_group.each do |keys| #[:RadioButton, :Category, :Original]
      p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
    end
    p_hsh
  end

  def build_fgs(key_group, store, p_hsh)
    return p_hsh if !key_group
    key_group.each do |key_set|
      modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
        p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
      end
    end
    p_hsh
  end

  def build_fgo(key_group, store, p_hsh, products)
    return products << p_hsh if !key_group
    set = build_kind_sets(key_group, store)
    combined_fields(set.group_by(&:kind).values).each do |f_hsh|
      p_hsh['p'].each {|k,v| f_hsh[k] = v}
      products << {'p' => f_hsh, 'tags' => p_hsh['tags']}
    end
    products
  end

  def build_kind_sets(key_group, store, set=[])
    key_group.map{|keys| modulize(keys[0], keys[1]).opts[keys[2]]}.flatten(1).each do |key_set|
      set << store.dig(*key_set)
    end
    set
  end

  def combined_fields(grouped_fields)
    grouped_fields[0].product(*grouped_fields[1..-1]).map{|a| a.group_by(&:kind).transform_values{|v| v[0]}.transform_keys{|k| k.to_sym}}
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
    return {k => v} if keys.empty?
    keys.map{|key| [key, {}]}.append([k,v]).transpose
  end

  def build_key_group(set, field_type, kind)
    set.map{|key| [field_type, kind, key]}
  end

end
