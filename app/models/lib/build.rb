module Build

  ##############################################################################
  # a = Build.seed_products ####################################################

  def self.seed_products
    [PRD, GBPRD, APRD].each do |mod|
      mod.product_module_cascade(seed_field_groups).each do |p|
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

  def combined_fields(grouped_fields)
    grouped_fields[0].product(*grouped_fields[1..-1]).map{|a| a.group_by(&:kind).transform_values{|v| v[0]}.transform_keys{|k| k.to_sym}}
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

  def build_product(p, tags, product={})
    product['options'] = sort_fields(p)
    product['tags'] = build_tags(p, tags)
    product['name'] = product_name(product['tags'])
    Product.builder(product['name'], product['options'], product['tags'])
  end

  def sort_fields(p)
    p_set = field_order.each_with_object([]) do |k, p_set|
      p_set << p[k] if p.has_key?(k)
    end
  end

  def field_order
    [:Embellished, :Category, :Edition, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate]
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
      name = class_to_cap(tags[k])
      name = k == 'material' ? "on #{name}" : name
      name_set << name
    end
  end

  def class_to_cap(class_word)
    class_word.underscore.split('_').map{|word| word.capitalize}.join(' ')
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
  #h = Build.seed_field_groups #################################################
  def self.seed_field_groups
    PRD.assoc_fields(PRD.seed_fields)
  end

  def assoc_fields(store)
    store = store[:parents].each_with_object(store) do |parent, store|
      f, targets = parent.values
      dig_and_assoc(f, targets, store)
    end
  end

  def seed_fields(store={parents:[]})
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

  def add_field(f_class, f_name, kind)
    f_class.where(field_name: f_name, kind: kind).first_or_create
  end

  def merge_field(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
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

end

# def dig_and_assign(target_sets, store, p)
#   p = dig_fields(target_sets, store).each_with_object(p) do |f, p|
#     merge_field(Item.dig_set(k: f.kind.to_sym, v: f, dig_keys:['p']), p)
#   end
# end

# def module_name(key)
#   field_hsh.invert[key.to_s].to_sym
# end
