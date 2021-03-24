class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  # object methods #############################################################
  def add_obj(obj)
    @item.assoc_unless_included(obj)
  end

  def remove_obj(f_obj)
    @item_groups.where(target_id: f_obj.id, target_type: f_obj.class.name).first.destroy
  end

  def replace_obj(new_obj, old_obj)
    remove_obj(old_obj)
    add_obj(new_obj)
  end
  ##############################################################################

  # field methods ##############################################################
  def add_param(f_type, f_name, new_val)
    if f_type == 'tags'
      @tags.merge!({f_name => new_val})
    else
      add_field(new_val, f_name)
    end
  end

  def remove_param(f_type, f_name, f_val)
    if f_type == 'tags'
      remove_tag(f_name)
    else
      remove_field(f_val, f_name)
    end
  end

  def replace_param(f_type, f_name, new_val, old_val)
    remove_param(f_type, f_name, old_val)
    add_param(f_type, f_name, new_val)
  end

  def add_field(f, f_name)
    @item.assoc_unless_included(f)
    @tags.merge!({f_name => f.id})
    cascade_add(f.param_args(field_groups: f.g_hsh)) if params[:controller] == 'item_fields'
  end

  def remove_field(f, f_name)
    remove_field_set_fields(f.param_args(field_groups: f.g_hsh)) if params[:controller] == 'item_fields'
    remove_obj(f)
    remove_tag(f_name)
  end

  def remove_tag(f_name)
    @tags.reject!{|k,v| f_name == k}
  end
  ##############################################################################

  # cascade methods ############################################################
  def cascade_add(param_args)
    param_args.each do |f_hsh|
      if f_obj = default_field(f_hsh[:k], f_hsh[:t], f_hsh[:f_obj])
        add_field(f_obj, f_hsh[:f_name])
      end
    end
  end

  def default_field(k, f_type, f_obj)
    if f_type == 'select_field'
      default_option(k, f_obj)
    elsif k == 'dimension' && f_type == 'select_menu'
      f_obj.fieldables.first
    end
  end

  def default_option(k, f_obj)
    if %w[edition material signature certificate].include?(k)
      f_obj.fieldables.first
    elsif k == 'medium'
      f_obj.fieldables.detect{|f| f_obj.field_name == compound_classify(f.field_name)}
    end
  end

  ##############################################################################

  # utility methods ############################################################
  def find_target(target_type, target_id)
    to_class(target_type).find(target_id)
  end

  def to_class(type)
    type.classify.constantize
  end

  def present_field_attr?(t, val)
    t.to_s != 'tags' && !val.blank?
  end

  def compound_classify(name)
    name.split(' ').join('_').classify
  end

  def hsh_init(h)
    h ? h : {}
  end
  ##############################################################################



  #show ########################################################################
  def search_input_group
    h={type: Product, inputs: search_tag_inputs, selected: selected_search_tag_inputs, item_id: @item.try(:id), product_id: @product.try(:id)}
  end

  def products
    Product.tags_search(h = {tag_params: search_params, default_set: :product_group}.compact)
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
    Product.tag_search_field_group(args).transform_values{|opts| opts.map{|opt| h={text: format_text_tag(opt), value: opt}}}
  end

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
    when @product && (action_name == 'show' || action_name == 'update') then Product.valid_search_keys([@product])
    when !@product && (action_name == 'show' || action_name == 'update') then derive_search_keys
    when action_name == 'search' then derive_search_keys
    end
  end

  def derive_search_params
    Product.tag_search_field_group(search_keys: search_keys, products: [@product]).each {|k,v| v.prepend(k.to_s)}.values
  end

  def derive_search_keys
    Product.filter_keys
  end

  def derive_search_tag_inputs
    Product.filter_keys.map{|k| [k, build_tag_value(k)]}
  end

  def build_tag_value(k)
    if params[:items] && params[:items][:search].keys.include?(k)
      params[:items][:search][k]
    else
      'all'
    end
  end

  # def product_type
  #   if params[:items] && !params[:items][:search][:type].blank?
  #     params[:items][:search][:type]
  #   elsif @product && action_name == 'show'
  #     @product.type
  #   else
  #     default_product_type
  #   end
  # end

  # def default_product_type
  #   Product.ordered_types.first
  # end

  def format_text_tag(tag_value)
    tag_value.underscore.split('_').join(' ').sub('one of a kind', 'One-of-a-Kind').split(' ').map{|w| w.capitalize}.join(' ')
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

  def remove_assoc(origin, target)
    remove_item_fields if target.try(:type) && target.base_type == 'Product'
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
    update_default_fields(@item.product_group['inputs']) if target.try(:type) && target.base_type == 'Product'
    a, b = origin, target
  end

  # update_product_fields ####################################################
  def update_product
    return if [:add, :remove, :replace, nil].include?(@context)
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
      add_field(f_hsh[:collection][0].id, {}) if %w[category_id material_id medium_id].include?(f_hsh[:method]) #|| f_hsh[:method] == 'medium_id' && f_hsh[:collection].count == 1
    end
  end

  def update_default_field_sets_hsh(field_sets_hsh)
    field_sets_hsh.each do |kind, f_set|
      f_set.each do |f_hsh|
        next if %w[dimension numbering signature certificate].exclude?(kind)
        if f_hsh[:render_as] == 'select_menu'
          target = f_hsh[:collection][0]
          add_field(target.id, {})
          add_nested_defaults(target)
        elsif f_hsh[:render_as] == 'select_field'
          target = f_hsh[:collection][0]
          add_field(target.id, {})
        end
      end
    end
  end

  def add_nested_defaults(origin)
    if origin.type == "FieldSet"
      add_default_field_set_targets(origin.targets)
    elsif origin.type == "SelectField"
      add_field(origin.id, {}) #<SelectField>
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

  def remove_item_fields
    return if @item.field_targets.empty?
    @item.tags = nil if @item.tags
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
      #puts "tags: #{tags}, param_tags[tag_key]: #{param_tags[tag_key]}"
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
  def update_fk(id, param_id, f_param={})
    return if skip_field_update(id, param_id)
    if id.present? && param_id.blank?
      remove_field(id, f_param)
    elsif id.present? && (id != param_id.to_i)
      replace_field(id, param_id, f_param)
    elsif id.blank? && param_id.present?
      add_field(param_id, f_param)
    end
  end

  # def cascade_remove(f_params)
  #   f_params.each do |k, v|
  #     if k.split('_').last == 'id'
  #       f_params[k] = ""
  #     elsif k == 'options' || k == 'tags'
  #       f_params[k].each {|key, v| f_params[k][key] = ""}
  #     end
  #   end
  #   f_params
  # end

  def skip_field_update(id, param_id)
    (id.blank? && param_id.blank?) || (id == param_id.to_i)
  end

  # def remove_field(id, f_params)
  #   @item.item_groups.where(target_id: id).first.destroy
  #   cascade_remove(f_params) if !f_params.empty?
  # end

  # def replace_field(id, param_id, f_params)
  #   remove_field(id, f_params)
  #   add_field(param_id, f_params)
  # end

  # def add_field(param_id, f_params)
  #   target = FieldItem.find(param_id)
  #   target = to_class(target.type).find(param_id)
  #   @item.assoc_unless_included(target)
  #   cascade_remove(f_params) if !f_params.empty?
  # end

  #utility methods #############################################################
  # def to_class(type)
  #   type.classify.constantize
  # end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  def filter_keys
    %w[medium_category medium material]
  end

end
