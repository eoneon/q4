class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  #show ########################################################################
  def search_input_group
    h={type: product_type, inputs: search_tag_inputs, selected: selected_search_tag_inputs, item_id: @item.try(:id), product_id: @product.try(:id)}
  end

  def products
    to_class(product_type).tags_search(h = {tag_params: search_params, default_set: :product_group}.compact)
  end

  #case 1: [["medium_category", "standard_print"], ["medium", "basic_print"], ["material", "metal"]]
  #case 2: nil
  def search_params
    case
    when (action_name == 'show' && @product) || (action_name == 'update' && @product) || (action_name == 'search' && revert_to_product_type) then derive_search_params
    when (action_name == 'show' || action_name == 'update') && !@product then nil
    when action_name == 'search' then derive_search_tag_inputs
    end
  end

  def revert_to_product_type
    @product && (params[:items][:search][:type] != params[:hidden][:search][:type]) && (params[:items][:search][:type] == @product.type)
  end

  # tag_search_field_group(search_keys, @products)
  def search_tag_inputs
    args={search_keys: search_keys, products: @products}.compact
    to_class(product_type).tag_search_field_group(args).transform_values{|opts| opts.map{|opt| h={text: format_text_tag(opt), value: opt}}}
  end

  #this is really: selected_search_tag_inputs
  #case 1: [["medium_category", "standard_print"], ["medium", "basic_print"], ["material", "metal"]]
  #case 2: [["medium_category", "all"], ["medium", "all"], ["material", "all"]]
  def selected_search_tag_inputs
    case
    when (@product && (action_name == 'show' || action_name == 'update')) || (action_name == 'search' && revert_to_product_type) then search_params.to_h
    when (!@product && (action_name == 'show' || action_name == 'update')) then derive_search_tag_inputs.to_h
    when action_name == 'search' then derive_search_tag_inputs.to_h
    end
  end

  # case 1: ["medium_category", "medium", "material"]
  def search_keys
    case
    when @product && (action_name == 'show' || action_name == 'update') then to_class(product_type).valid_search_keys([@product])
    when !@product && (action_name == 'show' || action_name == 'update') then derive_search_keys
    when action_name == 'search' then derive_search_keys
    end
  end

  def derive_search_params
    to_class(product_type).tag_search_field_group(search_keys: search_keys, products: [@product]).each {|k,v| v.prepend(k.to_s)}.values
  end

  def derive_search_keys
    to_class(product_type).filter_keys #.map{|k| [k, build_tag_value(k)]}
  end

  def derive_search_tag_inputs
    to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
  end

  def build_tag_value(k)
    if params[:items] && params[:items][:search].keys.include?(k)
      params[:items][:search][k]
    else
      'all'
    end
  end

  def product_type
    if params[:items] && !params[:items][:search][:type].blank?
      params[:items][:search][:type]
    elsif @product && action_name == 'show'
      @product.type
    else
      default_product_type
    end
  end

  def default_product_type
    Product.ordered_types.first
  end

  def format_text_tag(tag_value)
    tag_value = [['paper_only', '(paper only)'], ['standard', ''], ['limited_edition', 'ltd ed'], ['one_of_a_kind', 'one-of-a-kind']].map{|set| tag_value.sub(set[0], tag_value[1])}[0]
    tag_value = tag_value.split('_')
    [tag_value[0..-2], tag_value[-1]].join(' ')
  end

  # update_product #############################################################
  def update_assocs(origin, target, params_target_type, params_target_id)
    @context = update_context(origin, target, params_target_type, params_target_id)
    if @context == :skip
      a, b = origin, target
    elsif @context == :remove
      remove_assoc(origin, target)
    elsif @context == :replace
      replace_assoc(origin, target, params_target_type, params_target_id.to_i)
    elsif @context == :add
      add_assoc(origin, target, params_target_type, params_target_id)
    end
  end

  # update_product #############################################################
  def update_context(origin, target, params_target_type, params_target_id)
    if (params_target_id.blank? && target.blank?) || (params_target_id.to_i == target.try(:id))
      :skip
    elsif target.present? && params_target_id.blank?
      :remove
    elsif target.present? && (params_target_id.to_i != target.id)
      :replace
    elsif target.blank? && params_target_id.present?
      :add
    end
  end

  # def update_assocs(origin, target, params_target_type, params_target_id)
  #   if skip_update_assocs(origin, target, params_target_type, params_target_id)
  #     a, b = origin, target
  #   elsif target.present? && params_target_id.blank?
  #     remove_assoc(origin, target)
  #   elsif target.present? && (params_target_id.to_i != target.id)
  #     replace_assoc(origin, target, params_target_type, params_target_id.to_i)
  #   elsif target.blank? && params_target_id.present?
  #     add_assoc(origin, target, params_target_type, params_target_id)
  #   end
  # end

  def skip_update_assocs(origin, target, params_target_type, params_target_id)
    (params_target_id.blank? && target.blank?) || (params_target_id.to_i == target.try(:id))
  end

  def remove_assoc(origin, target)
    remove_item_fields if target.base_type == 'Product'
    origin.item_groups.where(target_id: target.id).first.destroy
    target = nil
    a, b = origin, target
  end

  def replace_assoc(origin, target, params_target_type, params_target_id)
    remove_assoc(origin, target)
    a, b = add_assoc(origin, target, params_target_type, params_target_id)
  end

  def add_assoc(origin, target, params_target_type, params_target_id)
    target = to_class(params_target_type).find(params_target_id)
    origin.assoc_unless_included(target)
    update_default_fields(@item.product_group['inputs']) if target.base_type == 'Product'
    a, b = origin, target
  end

  # update_product_fields ####################################################
  # def update_product
  #   product_group = @item.product_group
  #   if f_params = field_params
  #     update_fields(product_group['params'], f_params)
  #   else
  #     update_default_fields(product_group['inputs'])
  #   end
  # end

  def update_product
    return if [:add, :remove, :replace, nil].include?(@context) #|| !field_params
    update_fields(@item.product_group['params'], field_params)
  end

  def update_fields(i_params, f_params)
    i_params.keys.each do |f_type|
      if f_type == 'field_sets'
        update_field_sets(i_params[f_type], f_params[f_type])
      elsif f_type == 'options'
        update_options(i_params[f_type], f_params[f_type])
      end
    end
  end

  def update_default_fields(inputs)
    inputs.keys.each do |f_type|
      if f_type == 'field_sets'
        update_default_field_sets_hsh(inputs['field_sets'])
      elsif f_type == 'options'
        update_default_options_hsh(inputs['options'])
      end
    end
  end

  def update_default_options_hsh(options_hsh)
    options_hsh.each do |f_hsh|
      add_field(f_hsh[:collection][0].id, {})
    end
  end

  def update_default_field_sets_hsh(field_sets_hsh)
    field_sets_hsh.each do |kind, f_set|
      f_set.each do |f_hsh|
        if f_hsh[:render_as] == 'select_menu'
          target = f_hsh[:collection][0]
          add_field(target.id, {})
          add_nested_defaults(target)
        end
      end
    end
  end

  def add_nested_defaults(origin)
    if origin.type == "FieldSet"
      add_default_field_set_targets(origin.targets)
    elsif origin.type == "SelectField"
      add_field(origin.id, {}) #<Option>
      add_field(origin.targets[0].id, {}) #<Option>
    elsif origin.type == "SelectMenu"
      add_field(origin.id, {}) #<SelectMenu>
      if origin.targets[0].type == 'FieldSet'
        add_field(origin.targets[0].id, {}) #<FieldSet>
        add_default_field_set_targets(origin.targets[0].targets)
      elsif origin.targets[0].type == "SelectField"
        add_field(origin.targets[0].id, {}) #<SelectField>
        add_field(origin.targets[0].targets[0].id, {}) #<Option>
      end
    end
  end

  def add_default_field_set_targets(targets)
    targets.each do |target|
      add_nested_defaults(target)
    end
  end

  def field_params
    {"options" => params[:item][:options], "field_sets" => params[:item][:field_sets]} unless [:options, :field_sets].detect {|k| !params[:item].has_key?(k)}
  end
  #kill
  def remove_product_fields
    if params[:hidden][:product_id].blank?
      field_targets = @item.field_targets
      return if field_targets.empty?
      field_targets.each do |target|
        @item.item_groups.where(target_id: target.id, target_type: target.type).first.destroy
      end
    end
  end

  def remove_item_fields
    return if @item.field_targets.empty?
    @item.field_targets.each do |target|
      @item.item_groups.where(target_id: target.id, target_type: target.type).first.destroy
    end
  end

  ############################
  def update_field_sets(fs, params_fs)
    fs.each do |kind_key, kind_hsh|
      update_kind_hsh(kind_hsh, params_fs[kind_key])
    end
  end

  def update_kind_hsh(kind_hsh, params_kind_hsh)
    kind_hsh.each do |k,v|
      if k.split('_').last == 'id'
        update_fk(v.try(:id), params_kind_hsh[k], params_kind_hsh)
      elsif k == 'options'
        update_options(kind_hsh[k], params_kind_hsh[k])
      elsif k == 'tags'
        update_tags(kind_hsh[k], params_kind_hsh[k])
      end
    end
  end

  def update_options(opts, params_opts)
    opts.each do |opts_key, opt|
      update_fk(opt.try(:id), params_opts[opts_key])
    end
  end

  def update_tags(tags, param_tags)
    tags.each do |tag_key, tag|
      param_tag = param_tags[tag_key]
      assign_or_merge(tag_key, param_tag) unless (tag.blank? && param_tag.blank?) || (tag == param_tag)
    end
  end

  def assign_or_merge(tag_key, param_tag)
    if @item.tags
      @item.tags[tag_key] = param_tag
    else
      @item.tags = {tag_key => param_tag}
    end
  end

  # CRUD methods for update_fields
  #def update_fk(id, param_id)
  def update_fk(id, param_id, f_param={})
    return if skip_field_update(id, param_id)
    if id.present? && param_id.blank?
      #remove_field(id)
      remove_field(id, f_param)
    elsif id.present? && (id != param_id.to_i)
      #replace_field(id, param_id)
      replace_field(id, param_id, f_param)
    elsif id.blank? && param_id.present?
      #add_field(param_id)
      add_field(param_id, f_param)
    end
  end

  def cascade_remove(f_params)
    f_params.each do |k, v|
      if k.split('_').last == 'id'
        f_params[k] = ""
      elsif k == 'options' || k == 'tags'
        f_params[k].each {|key, v| f_params[k][key] = ""}
      end
    end
    f_params
  end

  def skip_field_update(id, param_id)
    (id.blank? && param_id.blank?) || (id == param_id.to_i)
  end

  def remove_field(id, f_params)
  #def remove_field(id)
    @item.item_groups.where(target_id: id).first.destroy
    cascade_remove(f_params) if !f_params.empty?
  end

  def replace_field(id, param_id, f_params)
  #def replace_field(id, param_id)
    remove_field(id, f_params)
    #remove_field(id)
    #add_field(param_id)
    add_field(param_id, f_params)
  end

  #def add_field(param_id)
  def add_field(param_id, f_params)
    target = FieldItem.find(param_id)
    target = to_class(target.type).find(param_id)
    @item.assoc_unless_included(target)
    cascade_remove(f_params) if !f_params.empty?
  end

  #utility methods #############################################################
  def to_class(type)
    type.classify.constantize
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  def filter_keys
    %w[medium_category medium material]
  end

end
