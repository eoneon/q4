module Build

  def context_build(fieldable:, field_name:, kind:, tags:nil, targets:[])
    field = fieldable.where(field_name: field_name, kind: kind, tags: tags).first_or_create
    puts "targets inside context_build: #{targets}"
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
    const_name = keys.map{|k| k.to_s}.join('::')
    const_name.constantize
  end

  def module_name(key)
    field_hsh.invert[key.to_s].to_sym
  end
  def field_hsh
    {'OPT' => 'Option', 'RBTN' => 'RadioButton', 'FSO' => 'FieldSet', 'SFO' => 'SelectField', 'SMO' => 'SelectMenu', 'NF' => 'NumberField', 'TF' => 'TextField', 'TFA' => 'TextAreaField'}
  end

  ##############################################################################
  def seed_build(store:{})
    seed_opt_set(store: store)
    seed_field_group(store: store)
    store
  end

  def seed_opt_set(store:{})
    [OPT, NF, TF, TFA].each do |k|
      k.cascade_build(store: store)
    end
    store
  end

  def seed_field_group(store:{})
    [SFO, FSO, SMO].each do |k|
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
        build_and_merge(field_class, key, kind, key_group, store)
      end
    end
    store
  end

  def build_and_merge(fieldable, field_name, kind, key_group, store)
    targets = build_targets(key_group, store)
    field = context_build(fieldable: fieldable, field_name: field_name, kind: kind, targets: targets)
    dig_set = dig_set(field_name, field, field.type.to_sym, kind)
    puts "dig_set inside build_and_merge: #{dig_set}"
    #params_merge(params: store, dig_set: dig_set(field_name, field, field.type.to_sym, kind))
    params = params_merge(params: store, dig_set: dig_set)
    puts "params inside build_and_merge: #{params}"
  end

  def build_targets(key_group, store, targets=[])
    puts "targets before assignment inside build_targets: #{targets}"
    key_group.each do |key_set|
      puts "key_set: #{key_set}"
      target = build_target(key_set, store)
      #puts "target: #{target}"
      targets << target
    end
    targets.compact.flatten
  end

  def build_target(key_set, store)
    if !store.dig(*key_set)
      #cascade_build_target(key_set, store)
      cascade_build_target(key_set[0], key_set[1], key_set[2], store)
    else
      target = store.dig(*key_set)
      puts "target inside build_target from store.dig: #{target}"
      target
    end
  end

  #def cascade_build_target(key_set, store)
  def cascade_build_target(type, kind, key, store)
    #key_group = modulize(module_name(key_set[0]), key_set[1]).opts[key_set[2]]
    key_group = modulize(module_name(type), kind).opts[key]
    puts "key_group inside cascade_build_target: #{key_group}"
    target = build_and_merge(modulize(type), key, kind, key_group, store)
    puts "target inside cascade_build_target #{target}"
    target
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

end
