class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  #show ########################################################################
  def search_input_group
    #h={type: product_type, inputs: search_tag_inputs, selected: selected_search_tag_inputs}
    h={type: product_type, inputs: search_tag_inputs}
  end

  def prev_selected
    h={type: product_type, inputs: selected_search_tag_inputs}
  end

  def products
    to_class(product_type).tags_search(product_args)
  end

  def product_args
    case
    when action_name == 'show' then h = {tag_params: search_params, default_set: :product_group}.compact
    when action_name == 'search' then h={tag_params: search_params} #to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
    end
  end

  def search_params
    case
    when action_name == 'show' && @product then search_params_from_search_keys_for_show_with_product
    when action_name == 'show' && !@product then nil
    when action_name == 'search' then to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
    end
  end

  def search_tag_inputs
    case
    when action_name == 'show' && @product then search_tag_inputs
    when action_name == 'show' && !@product then search_tag_inputs.keys.map{|k| [k, 'all']}
    when action_name == 'search' then to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
    end
  end

  def search_keys
    case
    when action_name == 'show' && @product then to_class(product_type).valid_search_keys([@product])
    when action_name == 'show' && !@product then to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
    when action_name == 'search' then to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
    end
  end

  def search_params_from_search_keys_for_show_with_product
    to_class(product_type).tag_search_field_group(search_keys, [@product]).each {|k,v| v.prepend(k.to_s)}.values
  end

  def build_tag_value(k)
    if params[:items][:search].keys.include?(k) #params[:items][:search][:tags].keys.include?(k)
      params[:items][:search][k] #params[:items][:search][:tags][k]
    else
      'all'
    end
  end

  def product_type
    if params[:items]
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
  # def selected_search_tag_inputs
  #   if @product
  #     search_tag_inputs
  #   else
  #     search_tag_inputs.keys.map{|k| [k, 'all']}
  #   end
  # end

  # def search_tag_inputs
  #   if @product
  #     search_params
  #   else
  #     to_class(product_type).tag_search_field_group(search_keys, @products)
  #   end
  # end




  # def search_params
  #   to_class(product_type).tag_search_field_group(search_keys, [@product]) if @product
  # end

  #search ######################################################################

  # def search_params
  #   to_class(product_type).filter_keys.map{|k| [k, build_tag_value(k)]}
  # end





  ##############################################################################
  def selected
    h={type: params[:items][:search][:type], tags: params[:items][:search][:tags]}
  end

  def product_items_on_search
    search_type, hidden_type, tag_params = params[:items][:search][:type], params[:hidden][:search][:type], params[:items][:search]
    @products = products_on_search(search_type, hidden_type, tag_params)
    @input_group = to_class(search_type).search_inputs(@products, selected_hsh_on_search, 'items_search')
  end

  #HERE! start search select inputs #############################################################################
  def product_items_on_show
    @products = to_class(selected_type).tags_search(tag_params: selected_tags, default_set: :product_group)
  end

  def hidden_search
    h={product_id: params[:hidden][:search][:product_id], type: params[:hidden][:search][:type], tags: params[:hidden][:search][:tags]}
  end

  def items_search
    h={type: params[:items][:search][:type], tags: params[:items][:search][:tags]}
  end

  # def search_context
  #   if @item.product && [@item.product.type, items_search[:type], hidden_search[:type]].uniq.count == 1
  # end

  #context: 'show'
  def selected_type
    @product ? @product.type : default_type
  end

  #context: 'show' selected_selects derived from: @product or
  def selected_tags
    @product ? filter_keys.map{|k| [k, format_selected_select_value(@product.tags[k])] if @product.tags.keys.include?(k)} : default_selects
  end

  def default_selects
    to_class(default_type).filter_keys.map{|tag_param| [tag_param, 'all']}
  end

  #context: 'show'
  def default_type
    Product.ordered_types.first
  end

  def format_selected_select_value(v)
    v.present? ? v : 'all'
  end

  def search_selects
    selected_selects.reject {|tag_set| tag_set[-1] == 'all'}
  end
  # end search_query #############################################################################

  # search_query #############################################################################
  def products_on_search(search_type, hidden_type, tag_params)
    search_context(search_type, hidden_type, tag_params)
  end

  # def search_context(search_type, hidden_type, tag_params)
  #   if @item.product && [@item.product.type, search_type, hidden_type].uniq.count == 1
  #     products = products_from_product
  #     selected = search_hsh_using_product_params
  #     products, selected, input_group = products, selected, to_class(search_type).search_inputs(products, selected, 'items_search')
  #   elsif @item.product && (search_type != hidden_type)
  #     products = products_from_type(search_type)
  #     selected = search_hsh_using_default_params(products)
  #     products, selected, input_group = products, selected, valid_search_params_on_search(tag_params, search_type)
  #   elsif
  #     products, selected = products_from_tags(search_type, tag_params), valid_search_params_on_search(tag_params, search_type)
  #   end
  # end

  def products_from_type(search_type)
    to_class(search_type).product_group
  end

  def products_from_tags(search_type, tag_params)
    to_class(search_type).kv_set_search(valid_search_tags(tag_params))
  end

  def selected_hsh_on_search
    if @product
      search_hsh_using_product_params
    else
      params[:items][:search].reject {|k,v| to_class(params[:items][:search][:type]).valid_search_keys(@products, filter_keys).exclude?(k)}
    end
  end

  def selected_hsh_on_search
    valid_search_params_on_show
    #valid_search_params_on_search(params[:items][:search], params[:items][:search][:type])
  end

  def valid_search_params_on_search(search_hsh, search_type)
    search_hsh.reject {|k,v| Product.valid_search_keys(@products, filter_keys).exclude?(k)}
    #params[:items][:search].reject {|k,v| to_class(params[:items][:search][:type]).valid_search_keys(@products, filter_keys).exclude?(k)}
  end

  # def products
  #   case
  #   when action_name == "show" then products_on_show
  #   when action_name == "search" then products_on_search(params[:items][:search][:type], params[:hidden][:type], params[:items][:search])
  #   when action_name == "update" && products_on_update
  #   end
  # end

  def input_group
    if params[:items]
      to_class(params[:items][:search][:type]).search_inputs(@products, selected_hsh, 'items_search')
    else
      StandardProduct.search_inputs(@products, selected_hsh, 'items_search')
    end
  end

  def selected_hsh
    case
    when action_name == "show" then valid_search_params_on_show
    when action_name == "search" then valid_search_params_on_search(params[:items][:search], params[:items][:search][:type])
    when action_name == "update" then valid_search_params_on_update
    end
  end

  ######### selected_hsh: after update #########################################
  def valid_search_params_on_update
    if @product
      search_hsh_using_product_params
    else
      search_hsh_using_default_params(products)
    end
  end

  ######### selected_hsh: after search ######################################### search_hsh_using_products


  ######### selected_hsh #######################################################
  def valid_search_params_on_show
    if @product
      search_hsh_using_product_params
    else
      search_hsh_using_default_params(products)
    end
  end

  def search_hsh_using_product_params
    valid_product_search_tags.to_h
  end
  #to_class(search_type) => params[:items][:search][:type]
  def search_hsh_using_default_params(products)
    #to_class(product_type).valid_search_keys()
    #Product.valid_search_keys(products, filter_keys).map{|tag_param| [tag_param, 'all']}.to_h
    Product.valid_search_keys(products).map{|tag_param| [tag_param, 'all']}.to_h
  end



  def products_on_show
    if @product
      products_from_product
    else
      default_products
    end
  end



  def products_on_update
    if @product
      to_class(@product.type).kv_set_search(valid_product_search_tags)
    else
      default_products
    end
  end

  def products_from_product
    to_class(@product.type).kv_set_search(valid_product_search_tags)
  end

  def default_products
    StandardProduct.product_group
  end

  ##############################################################################

  # def search_query(product, type, tag_params)
  #   if !product || (product.type != type)
  #     #type = !product ? type :
  #     to_class(type).product_group
  #   else
  #     to_class(product.type).kv_set_search(valid_search_tags(tag_params))
  #   end
  # end

  #remove_empty_all
  def valid_search_tags(tag_params, v2='all')
    tag_params = tag_params.reject {|k,v| v == v2 || v.empty? || k == 'type'}.each {|k,v| [k,v]}
    if tag_params.any?
      tag_params
    end
  end

  #replaces: build_kv_set
  def valid_product_search_tags
    @product.tags.keys.map {|k| [k, @product.tags[k]] if filter_keys.include?(k)}.compact
  end

  ##############################################################################

  def update_assocs(origin, target, params_target_type, params_target_id)
    if target.present? && params_target_id.blank?
      remove_assoc(origin, target)
    elsif target.present? && (params_target_id != target.id)
      replace_assoc(origin, target, params_target_type, params_target_id)
    elsif target.blank? && params_target_id.present?
      add_assoc(origin, target, params_target_type, params_target_id)
    end
  end

  def remove_assoc(origin, target)
    #puts "1 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    origin.item_groups.where(target_id: target.id).first.destroy
    target = nil
    a, b = origin, target
  end

  def replace_assoc(origin, target, params_target_type, params_target_id)
    #puts "2 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    remove_assoc(origin, target)
    add_assoc(origin, target, params_target_type, params_target_id)
    a, b = origin, target
  end

  def add_assoc(origin, target, params_target_type, params_target_id)
    #puts "3 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    target = to_class(params_target_type).find(params_target_id)
    origin.assoc_unless_included(target)
    a, b = origin, target
  end

  ##############################################################################

  def to_class(type)
    type.constantize
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  def filter_keys
    %w[medium_category medium material]
  end
end

# def hidden_type
#   params[:hidden][:search][:type]
# end
#
# def hidden_selects
#   params[:hidden][:search][:tags]
# end
#
# def hidden_product_id
#   params[:hidden][:search][:product_id]
# end
# def search_using_new_type_or_products_from_product(search_type)
#   if @product
#     products_from_product
#   else
#     products_from_type(search_type)
#   end
# end


# def search_query(search_type, hidden_type, tag_params)
#   if @item.product && [@item.product.type, search_type, hidden_type].uniq.count == 1
#     products_from_product
#   elsif @item.product && (search_type != hidden_type)
#     search_using_new_type(search_type)
#   else
#     search_using_tags(search_type, tag_params)
#   end
# end

# def search_query(search_type, hidden_type, tag_params)
#   if search_type != hidden_type
#     search_using_new_type(search_type)
#   else
#     search_using_tags(search_type, tag_params)
#   end
# end

# def selected_hsh
#   case
#   when action_name == "show" && @product then valid_product_search_tags(@product).to_h
#   when action_name == "search" then params[:hidden][:search].reject {|k,v| Product.valid_search_keys(@products, filter_keys).exclude?(k)}
#   when action_name == "update" && @product then valid_product_search_tags(@product).to_h
#   else Product.valid_search_keys(@products, filter_keys).map{|tag_param| [tag_param, 'all']}.to_h
#   end
# end

# def products
#   case
#   when action_name == "show" && @product then to_class(@product.type).kv_set_search(valid_product_search_tags(@product))
#   #when action_name == "search" then search_query(@product, params[:items][:search][:type], params[:items][:search])
#   when action_name == "search" then search_query(params[:items][:search][:type], params[:items][:search])
#   when action_name == "update" && @product then to_class(@product.type).kv_set_search(valid_product_search_tags(@product))
#   else StandardProduct.product_group
#   end
# end

  # def products
  #   case
  #   when action_name == "show" && @item.product then FieldSet.kv_set_search(build_kv_set(@item.product))
  #   when action_name == "search" then search_query
  #   when action_name == "update" && @product then FieldSet.kv_set_search(build_kv_set(@product))
  #   else FieldSet.media_set
  #   end
  # end
  #
  # def input_group
  #   FieldSet.search_inputs(@products, selected_hsh, 'items_search')
  # end
  #
  # def selected_hsh
  #   case
  #   when action_name == "show" && @item.product then build_kv_set(@item.product).to_h
  #   when action_name == "search" then params[:hidden][:search].reject {|k,v| search_tags.exclude?(k)}
  #   when action_name == "update" && @product then build_kv_set(@product).to_h
  #   else search_tags.map{|tag_param| [tag_param, 'all']}.to_h
  #   end
  # end
  #
  # def build_kv_set(product)
  #   product.tags.keys.map {|k| [k, product.tags[k]] if filter_keys.include?(k)}.compact
  # end
  #
  # def search_query
  #   if valid_search = valid_search_params
  #     FieldSet.kv_set_search(valid_search)
  #   else
  #     FieldSet.media_set
  #   end
  # end
  #
  # def valid_search_params
  #   search_params = params[:items][:search].reject {|k,v| v == 'all' || v.empty?}.each {|k,v| [k,v]}
  #   if search_params.any?
  #     search_params
  #   end
  # end
  #
  # #replaced by: Product.valid_search_keys(products, filter_keys)
  # def search_tags
  #   FieldSet.filter_keys(FieldSet.tag_set(@products), filter_keys)
  # end
