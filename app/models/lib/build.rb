module Build
  extend TypeCheck

  ##############################################################################
  # a = Build.seed_products ####################################################

  def self.seed_products
    set = [PRD, GBPRD, APRD].each_with_object([]) do |mod, set|
      mod.product_module_cascade(seed_fields).each do |p|
        mod.build_product(p['p'], p['tags'])
      end
    end
  end

  def product_module_cascade(store)
    products = cascade_args.each_with_object([]) do |args, products|
      p_cat, p_type, p_subtype, operation_group = args.values
      p = {'p'=>{}, 'tags'=>{'product_type'=> p_type.to_s, 'product_subtype'=> p_subtype.to_s}}
      build_product_group(operation_group, store, p, products)
    end
  end

  def build_product_group(operation_group, store, p, products)
    assign_target_fields(operation_group.dig(:key_group), store, p)
    assign_fgs(operation_group.dig(:FGS), store, p)

    if operation_val = operation_group.dig(:FGO)
      assign_fgo(fgo_options(operation_val, store), p, products)
    else
      products << p
    end

  end

  def assign_target_fields(target_sets, store, p)
    target_sets ? dig_and_assign(target_sets, store, p) : p
  end

  def assign_fgs(operation_val, store, p)
    operation_val ? dig_and_assign(flat_field_group(operation_val), store, p) : p
  end

  def fgo_options(operation_val, store)
    targets = flat_field_group(operation_val)
    fields = dig_fields(targets, store)
    combined_fields(fields.group_by(&:kind).values)
  end

  def assign_fgo(fgo_options, p, products)
    products = fgo_options.each_with_object(products) do |f_hsh, products|
      p['p'].each {|k,v| f_hsh[k] = v}
      products << {'p' => f_hsh, 'tags' => p['tags']}
    end
  end

  def field_group_targets(operation_val)
    operation_val.map{|target_keys| mod_group(*target_keys)}
  end

  def flat_field_group(operation_val)
    field_group_targets(operation_val).flatten(1)
  end

  def dig_fields(target_sets, store)
    target_sets.map{|f_keys| store.dig(*f_keys)}.flatten
  end

  def dig_and_assign(target_sets, store, p)
    p = dig_fields(target_sets, store).each_with_object(p) do |f, p|
      p['p'].merge!({f.kind.to_sym => f})
    end
  end
  ##############################################################################
  ##############################################################################
  def build_products(products)
    products.each do |p|
      build_product(p['p'], p['tags'])
    end
  end

  ##############################################################################
  def build_product(p, tags, product={})
    product['options'] = sort_fields(p)
    product['tags'] = build_tags(p, tags)
    product['name'] = product_name(product['tags'])
    Product.builder({product_name: product['name'], options: product['options'], tags: product['tags']})
  end

  def sort_fields(p)
    p_set = [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate].each_with_object([]) do |k, p_set|
      p_set << p[k] if p.has_key?(k)
    end
  end

  def build_tags(p, tags)
    tags = tag_keys.each_with_object(tags) do |k,tags|
      tags[k.to_s.underscore] = p[k].field_name if p.has_key?(k)
    end
  end

  def product_name(tags)
    format_name(edit_name(name_set(tags).join(' ')))
  end

  def name_set(tags)
    name_set = name_keys.each_with_object([]) do |k, name_set|
      next if !tags.dig(k)
      name = tags[k].underscore.split('_').map{|word| word.capitalize}.join(' ')
      name = k == 'material' ? "on #{name}" : name
      name_set << name
    end
  end

  def edit_name(name)
    name = [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['One Of One', 'One-of-One']].each_with_object(name) do |word_set|
      name.sub!(word_set[0], word_set[1])
    end
  end

  def format_name(name)
    name.split(' ').map(&:strip).join(' ')
  end

  def name_keys
    tag_keys.map{|k| k.to_s.underscore}
  end

  def tag_keys
    [:Category, :Medium, :Material]
  end

  ##############################################################################

  def combined_fields(grouped_fields)
    grouped_fields[0].product(*grouped_fields[1..-1]).map{|a| a.group_by(&:kind).transform_values{|v| v[0]}.transform_keys{|k| k.to_sym}}
  end

  ##############################################################################
  # h = Build.seed_fields ######################################################
  # def self.seed_fields
  #   store = {'parents'=[]}
  #   store = [OPT, NF, TF, TFA, RBTN, SFO, FSO, SMO].each_with_object(store) do |mod, store|
  #     mod.field_module_cascade(store)
  #   end
  # end

  # def field_module_cascade(store)
  #   cascade_args.each do |f_hsh|
  #     mod, sub_mod, opt_key, opt_enum = f_hsh.values
  #     targets = f_class.no_assoc? ? opt_enum : nested_args(f_class, opt_enum)
  #     field_build(f_class: f_class, f_name: opt_key, kind: sub_mod, dig_keys: [f_type.to_sym, sub_mod], targets: targets, store: store)
  #   end
  # end

  def nested_args(f_class, field_group)
    #return field_group if f_class.no_assoc?
    targets = field_group.each_with_object([]) do |f_keys, targets|
      targets.append({f_class: f_keys[0].to_s.constantize, f_name: f_keys[2], kind: f_keys[1], dig_keys: [f_keys[0],f_keys[1]], targets: nil}) #t,k,f_name = field_keys
      #dig_or_add_and_merge
    end
  end

  def field_build(f_class:, f_name:, kind:, dig_keys:, targets:, store:)
    if f_class.no_assoc?
      add_field_options(f_class, f_name, kind, dig_keys, targets, store)
    else
      add_and_assoc_targets_then_merge_field(f_class, f_name, kind, dig_keys, targets, store)
    end
  end


  ##############################################################################
  #h = Build.seed_field_groups #################################################
  def self.seed_field_groups
    PRD.assoc_fields(seed_fields)
  end

  def assoc_fields(store)
    store[:parents].each do |parent|
      f, targets = parent.values
      dig_and_assoc(f, targets, store)
    end
  end

  def self.seed_fields(store={parents:[]})
    store = [OPT, NF, TF, TFA, RBTN, SFO, FSO, SMO].each_with_object(store) do |mod, store|
      mod.field_module_cascade(store)
    end
  end

  def field_module_cascade(store)
    store = cascade_args.each_with_object(store) do |f_hsh, store|
      mod, k, f_name, targets = f_hsh.values
      if f_class.no_assoc?
        add_and_merge_targets(f_class, f_name, k, [f_type.to_sym, k], targets, store)
      else
        add_and_merge_parent(f_class, f_type.to_sym, k, f_name, targets, store)
      end
    end
  end

  def add_and_merge_targets(f_class, f_name, k, dig_keys, targets, store)
    targets = targets.map{|target_name| add_field(f_class, target_name, k)}
    merge_field(Item.dig_set(k: f_name, v: targets, dig_keys: dig_keys), store)
  end

  def add_and_merge_parent(f_class, t, k, f_name, targets, store)
    f = add_field(f_class, f_name, k)
    merge_field(Item.dig_set(k: f_name, v: f, dig_keys: [t, k]), store)
    store[:parents].append({f: f, targets: targets})
  end

  def dig_and_assoc(f, targets, store)
    dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
  end
  ##############################################################################
  ##############################################################################

  ##############################################################################
  #fields: add, assoc & merge methods ##########################################
  # def add_field_options(f_class, f_name, kind, dig_keys, targets, store)
  #   targets = targets.map{|target_name| add_field(f_class, target_name, kind)}
  #   merge_field(Item.dig_set(k: f_name, v: targets, dig_keys: dig_keys), store)
  # end

  def add_field(f_class, f_name, kind)
    f_class.where(field_name: f_name, kind: kind).first_or_create
  end

  def merge_field(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
  end

  def add_and_assoc_targets_then_merge_field(f_class, f_name, kind, dig_keys, targets, store)
    f = add_field(f_class, f_name, kind)
    add_and_merge_field_targets(targets, store).map{|target| f.assoc_unless_included(target)} if targets
    merge_field(Item.dig_set(k: f_name, v: f, dig_keys: dig_keys), store)
  end

  def add_and_merge_field_targets(targets, store)
    set = targets.each_with_object([]) do |args, set|
      add_and_assoc_targets_then_merge_field(args[:f_class], args[:f_name], args[:kind], args[:dig_keys], args[:targets], store)
    end
  end
  ##############################################################################
  ##############################################################################

  ##############################################################################
  #cascading loop method (2-levs) for collecting relevant module arguments ######
  def cascade_args
    a = constants.each_with_object([]) do |sub_mod, a|
      mod_opts(self, sub_mod).each do |opt_key, opt_enum|
        a.append({mod: self, sub_mod: sub_mod, opt_key: opt_key, opt_enum: opt_enum})
      end
    end
  end

  #methods for accessing opts hsh params #######################################
  def mod_group(t,k,f_name)
    mod_opts(t,k)[f_name]
  end

  def mod_opts(mod, sub_mod)
    modulize(mod, sub_mod).opts
  end

  #infer return value based on arguments #######################################
  def modulize(*keys)
    keys.map{|k| k.to_s}.join('::').constantize
  end

  def to_class(t)
    t.to_s.classify.constantize
  end

  #infer return value from file name and/or mod_hsh (context: top-level only) ##
  def mod_name(t)
    if module_name = mod_hsh.key(t)
      module_name
    elsif model_name = mod_hsh[t]
      model_name
    end
  end

  def f_class
    f_type.constantize
  end

  def f_type
    mod_hsh[name]
  end

  def mod_hsh
    {'OPT' => 'Option', 'RBTN' => 'RadioButton', 'FSO' => 'FieldSet', 'SFO' => 'SelectField', 'SMO' => 'SelectMenu', 'NF' => 'NumberField', 'TF' => 'TextField', 'TFA' => 'TextAreaField'}
  end

  def build_key_group(set, field_type, kind)
    set.map{|key| [field_type, kind, key]}
  end

end


  # def format_product(p, tags, product={})
  #   product['p'] = sort_fields(p)
  #   product['tags'] = build_tags(p, tags)
  #   product['name'] = build_name(product['tags'])
  #   Product.builder({product_name: product['name'], options: product['p'], tags: product['tags']})
  # end

  # def sort_fields(p, p_set=[])
  #   field_order.each do |k|
  #     p_set << p[k] if p.has_key?(k)
  #   end
  #   p_set
  # end

  # def field_order
  #   [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate]
  # end

  # def build_name(tags, name_set=[])
  #   name_keys.each do |k|
  #     next if !tags.dig(k)
  #     name = tags[k].underscore.split('_').map{|word| word.capitalize}.join(' ')
  #     name = k == 'material' ? "on #{name}" : name
  #     name_set << name
  #   end
  #   format_name(name_set.join(' '))
  # end

  # def build_tags(p, tags)
  #   tag_keys.each do |k|
  #     next if !p.has_key?(k)
  #     tags[k.to_s.underscore] = p[k].field_name
  #   end
  #   tags
  # end

  # def format_name(name)
  #   [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['One Of One', 'One-of-One']].each do |word_set|
  #     name.sub!(word_set[0], word_set[1])
  #   end
  #   name.split(' ').map(&:strip).join(' ')
  # end

# a = PRD.seed_product_type
# a.map{|h| {name: h['name'], tags: h['tags']}}
# a = Build.seed_products

# def self.seed_products(store: PRD.seed_fields, products: [])
#   [PRD, GBPRD, APRD].each do |prd|
#     prd.seed_product_type(store: store)
#   end
# end

##############################################################################
#type: sub_mod, sub_type: opt_key, field_group: opt_enum
# def seed_product_type(store: seed_fields, products: [])
#   constants.each do |type| #Painting
#     module_cascade(type, store, products)
#   end
#   format_products(products)
# end

# def module_cascade(type, store, products)
#   modulize(self, type).opts.each do |subtype, field_group| # StandardPainting, field_group
#     p_hsh = {'p'=>{}, 'tags'=>{'product_type'=> type.to_s, 'product_subtype'=> subtype.to_s}}
#     products = build_product_group(field_group, store, p_hsh, products)
#   end
#   products
# end

# def build_product_group(field_group, store, p_hsh, products)
#   build_kg(field_group.dig(:key_group), store, p_hsh)
#   build_fgs(field_group.dig(:FGS), store, p_hsh)
#   build_fgo(field_group.dig(:FGO), store, p_hsh, products)
# end

# def build_kg(key_group, store, p_hsh)
#   return p_hsh if !key_group
#   key_group.each do |keys| #[:RadioButton, :Category, :Original]
#     p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
#   end
#   p_hsh
# end
#
# def build_fgs(key_group, store, p_hsh)
#   return p_hsh if !key_group
#   key_group.each do |key_set|
#     modulize(key_set[0], key_set[1]).opts[key_set[2]].each do |keys|
#       p_hsh['p'].merge!({keys[1] => store.dig(*keys)})
#     end
#   end
#   p_hsh
# end
#
# def build_fgo(key_group, store, p_hsh, products)
#   return products << p_hsh if !key_group
#   set = build_kind_sets(key_group, store)
#   combined_fields(set.group_by(&:kind).values).each do |f_hsh|
#     p_hsh['p'].each {|k,v| f_hsh[k] = v}
#     products << {'p' => f_hsh, 'tags' => p_hsh['tags']}
#   end
#   products
# end
#
# def build_kind_sets(key_group, store, set=[])
#   key_group.map{|keys| modulize(keys[0], keys[1]).opts[keys[2]]}.flatten(1).each do |key_set|
#     set << store.dig(*key_set)
#   end
#   set
# end

# def target_opts(t,k)
#   modulize(t,k).opts
# end

##############################################################################
#field_build(field_args(*f_hsh.values.append(store)))
# def field_args(mod, sub_mod, opt_key, opt_enum, store)
#   {f_class: f_class, f_name: opt_key, kind: sub_mod, dig_keys: [f_type.to_sym, sub_mod], targets: nested_args(f_class, opt_enum), store: store}
# end
# def self.seed_fields
#   store = [OPT, NF, TF, TFA, RBTN, SFO, FSO, SMO].each_with_object({}) do |mod, store|
#     mod.cascade_seed(store)
#   end
# end
#
# def cascade_seed(store)
#   constants.each do |k|
#     target_opts(self,k).each do |f_name, f_val|
#       field_build(f_class: f_class, f_name: f_name, kind: k, dig_keys: [f_type.to_sym, k], targets: nested_args(f_class, f_val), store: store)
#     end
#   end
# end

# def seed_fields
#   seed_field_assocs(store: seed_options)
# end

# def seed_options(store:{})
#   [OPT, NF, TF, TFA].each do |k|
#     k.cascade_build(store: store)
#   end
#   store
# end
#
# def seed_field_assocs(store:{})
#   [RBTN, SFO, FSO, SMO].each do |k|
#     k.cascade_assoc(store: store)
#   end
#   store
# end

##############################################################################

# def cascade_build(store:{})
#   constants.each do |kind|
#     modulize(self,kind).opts.each do |key, key_set|
#       opt_set = key_set.map{|opt| context_build(fieldable: field_class, field_name: opt, kind: kind)}
#       params_merge(params: store, dig_set: dig_set(key, opt_set, field_type.to_sym, kind))
#     end
#   end
#   store
# end

# def cascade_assoc(store:{})
#   constants.each do |kind|
#     modulize(self,kind).opts.each do |key, key_group|
#       build_and_merge(field_class, key, kind, build_targets(key_group, store), store)
#     end
#   end
#   store
# end
#
# def build_and_merge(fieldable, field_name, kind, targets, store)
#   field = context_build(fieldable: fieldable, field_name: field_name, kind: kind, targets: targets)
#   puts "#{params_merge(params: store, dig_set: dig_set(field_name, field, field.type.to_sym, kind))}"
# end

# def build_targets(key_group, store, targets=[])
#   key_group.each do |key_set|
#     targets << build_target(key_set, store)
#   end
#   targets.compact.flatten
# end
#
# def build_target(key_set, store)
#   if !store.dig(*key_set)
#     cascade_build_target(key_set[0], key_set[1], key_set[2], store)
#   else
#     store.dig(*key_set)
#   end
# end

# def cascade_build_target(type, kind, key, store)
#   key_group = modulize(module_name(type), kind).opts[key]
#   build_and_merge(modulize(type), key, kind, build_targets(key_group, store), store)
# end

##############################################################################

# def context_build(fieldable:, field_name:, kind:, tags:nil, targets:[])
#   field = fieldable.where(field_name: field_name, kind: kind, tags: tags).first_or_create
#   targets.map{|target| field.assoc_unless_included(target)} unless targets.empty?
#   field
# end

# def field_class
#   field_type.constantize
# end

# def field_module(key)
#   module_name(key).constantize
# end
#
# def field_type
#   field_hsh[name]
# end
#
# def module_name(key)
#   field_hsh.invert[key.to_s].to_sym
# end

# def field_hsh
#   {'OPT' => 'Option', 'RBTN' => 'RadioButton', 'FSO' => 'FieldSet', 'SFO' => 'SelectField', 'SMO' => 'SelectMenu', 'NF' => 'NumberField', 'TF' => 'TextField', 'TFA' => 'TextAreaField'}
# end

# def build_targets(target_group, store)
#   targets = target_group.each_with_object([]) do |field_keys, targets|
#     t, k, f_name = field_keys
#     targets << build_target(k, t, f_name, store)
#   end
# end
#
# def build_target(k, t, f_name, store)
#   if target = store.dig(t, k, f_name)
#     target
#   else
#     f = t.to_s.constantize.where(field_name: f_name, kind: k).first_or_create
#     Item.param_merge(params: store, dig_set: Item.dig_set(k: f_name, v: f, dig_keys: [t, k]))
#
#     puts "HERE!! k: #{k},t: #{t}, f_name: #{f_name}, field_hsh.key(t.to_s): #{field_hsh.key(t.to_s)}"
#     target_group = target_group(field_hsh.key(t.to_s), k, f_name)
#     puts "target_group inside build_target: #{target_group}"
#     build_origin_and_targets(t.to_s.constantize, k, f_name, target_group, store)
#   end
# end

##############################################################################
##############################################################################

# def build_args
#   a = constants.each_with_object([]) do |k, a|
#     target_opts(self,k).each do |f_name, f_val|
#       a.append({f_class: f_class, f_name: f_name, dig_keys: [f_class.type.to_sym, k], targets: target_args(f_class, f_val)})
#     end
#   end
# end
#
# def target_args(f_class, target_group)
#   return target_group if f_class.no_assoc?
#   targets = target_group.each_with_object([]) do |field_keys, targets|
#     t,k,f_name = field_keys
#     targets.append({f_class: t.to_s.constantize, f_name: f_name, dig_keys: [t,k]})
#   end
# end
