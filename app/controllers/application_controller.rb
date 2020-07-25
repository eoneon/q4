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

  # def product_args
  #   h = {tag_params: search_params, default_set: :product_group}.compact
  # end

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

  def update_assocs(origin, target, params_target_type, params_target_id)
    if skip_update_assocs(origin, target, params_target_type, params_target_id)
      a, b = origin, target
    elsif target.present? && params_target_id.blank?
      remove_assoc(origin, target)
    elsif target.present? && (params_target_id != target.id)
      replace_assoc(origin, target, params_target_type, params_target_id)
    elsif target.blank? && params_target_id.present?
      add_assoc(origin, target, params_target_type, params_target_id)
    end
  end

  def skip_update_assocs(origin, target, params_target_type, params_target_id)
    (params_target_id.blank? && target.blank?) || (params_target_id.to_i == target.try(:id))
  end

  def remove_assoc(origin, target)
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
    a, b = origin, target
  end

  #update product field selections #############################################
  def set_default_values_for_product
    product.field_targets.each do |f|
      default_values_for_product(f)
    end
  end

  def default_values_for_product(f)
    if f.type == 'SelectField'
      default_value_for_select_field(f)
    elsif f.type == 'SelectMenu'
      default_value_for_select_menu(f)
    elsif f.type == 'FieldSet'
      f.targets.map{|ff| default_values_for_product(ff)}
    end
  end

  def default_value_for_select_field(f)
    @item.options << f.options.first
  end

  def default_value_for_select_menu(f)
    @item.field_sets << f.field_sets.first
  end

  def remove_field_targets
    #@item.field_targets.destroy_all
  end

  ##############################################################################

  def to_class(type)
    type.classify.constantize
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  def filter_keys
    %w[medium_category medium material]
  end

  ##############################################################################
  def update_fields
    #@item.field_params
    i_params, f_params = @item.field_params, field_params
    #puts "i_params: #{i_params}, f_params: #{f_params}"
    i_params.keys.each do |f_type|
      cascade_field_update(i_params, f_params, f_type)
    end
  end

  def cascade_field_update(i_params, f_params, f_type)
    i_params[f_type].keys.each do |k|
      #if k.class.name == 'Hash'
      if i_params[f_type][k].class.name == 'Hash'
        #puts "Hash: #{k}"
        cascade_field_update(i_params[f_type], f_params[f_type], k)
      else
        #puts "f_params: #{f_params}"
        #puts "#{i_params[f_type][k]}, #{f_params[f_type][k]}"
        update_field_assoc(i_params[f_type][k], f_params[f_type][k], f_type.singularize)
      end
    end
  end

  def update_field_assoc(id, param_id, f_type)
    return if skip_field_update(id, param_id)
    if id.present? && param_id.blank?
      remove_field(id)
    elsif id.present? && (id != param_id.to_i)
      replace_field(id, param_id)
    elsif id.blank? && param_id.present?
      add_field(param_id, f_type)
    end
  end

  def remove_field(id)
    @item.item_groups.where(target_id: id).first.destroy
  end

  def replace_field(id, param_id)
    remove_field(id)
    add_field(param_id, f_type)
  end

  def add_field(param_id, f_type)
    target = to_class(f_type).find(param_id)
    @item.assoc_unless_included(target)
  end

  def skip_field_update(i_param, f_param)
    (i_param.blank? && f_param.blank?) || (i_param == f_param.to_i)
  end

  ##############################################################################

  def field_params
    h={"options" => opts_hsh, "field_sets" => fs_hsh}
  end

  def fs_hsh
    a, b, c = params[:item][:field_sets][:field_sets], params[:item][:field_sets].select{|k,v| k != 'options' && k != 'field_sets'}, []
    [a, b].each do |hsh|
      hsh.keys.each do |k|
        c << [k, hsh[k]]
      end
    end
    c.to_h.merge!(h={'options' => fs_opts_hsh})
  end

  def fs_opts_hsh
    params[:item][:field_sets][:options].keys.map{|k| [k, params[:item][:field_sets][:options][k]]}.to_h
  end

  def opts_hsh
    params[:item][:options].keys.map{|k| [k, params[:item][:options][k]]}.to_h
  end
  ##############################################################################
end

# def update_product
#   #@product = @item.product
#   #@artist = @item.artist
#   #set_product
#   @item, @product = update_assocs(@item, @item.product, params[:hidden][:type], params[:hidden][:product_id])
#   set_artist
#   @products = products
#   @input_group = search_input_group
#   puts "@product: #{@product.try(:id)}"
# end
