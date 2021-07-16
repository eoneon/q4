class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def hsh_init(tags)
    tags ? tags : {}
  end

end


#show ########################################################################
# def search_input_group
#   h={type: Product, inputs: search_tag_inputs, selected: selected_search_tag_inputs, item_id: @item.try(:id), product_id: @product.try(:id)}
# end
#
# def products
#   Product.tags_search(h = {tag_params: search_params, default_set: :product_group}.compact)
# end
#
# #case 1: [["medium_category", "standard_print"], ["medium", "basic_print"], ["material", "metal"]]
# #case 2: nil
# def search_params
#   case
#   when (action_name == 'show' && @product) || (action_name == 'update' && @product) || (action_name == 'search' && revert_to_product_type) then derive_search_params
#   when (action_name == 'show' || action_name == 'update') && !@product then nil
#   when action_name == 'search' then derive_search_tag_inputs
#   end
# end
#
# def revert_to_product_type
#   @product && (params[:items][:search][:type] != params[:hidden][:search][:type]) && (params[:items][:search][:type] == @product.type)
# end
#
# # tag_search_field_group(search_keys, @products)
# def search_tag_inputs
#   args={search_keys: search_keys, products: @products}.compact
#   Product.tag_search_field_group(args).transform_values{|opts| opts.map{|opt| h={text: format_text_tag(opt), value: opt}}}
# end
#
# #case 1: [["medium_category", "standard_print"], ["medium", "basic_print"], ["material", "metal"]]
# #case 2: [["medium_category", "all"], ["medium", "all"], ["material", "all"]]
# def selected_search_tag_inputs
#   case
#   when (@product && (action_name == 'show' || action_name == 'update')) || (action_name == 'search' && revert_to_product_type) then search_params.to_h
#   when (!@product && (action_name == 'show' || action_name == 'update')) then derive_search_tag_inputs.to_h
#   when action_name == 'search' then derive_search_tag_inputs.to_h
#   end
# end
#
# # case 1: ["medium_category", "medium", "material"]
# def search_keys
#   case
#   when @product && (action_name == 'show' || action_name == 'update') then Product.valid_search_keys([@product])
#   when !@product && (action_name == 'show' || action_name == 'update') then derive_search_keys
#   when action_name == 'search' then derive_search_keys
#   end
# end
#
# def derive_search_params
#   Product.tag_search_field_group(search_keys: search_keys, products: [@product]).each {|k,v| v.prepend(k.to_s)}.values
# end
#
# def derive_search_keys
#   Product.filter_keys
# end
#
# def derive_search_tag_inputs
#   Product.filter_keys.map{|k| [k, build_tag_value(k)]}
# end
#
# def build_tag_value(k)
#   if params[:items] && params[:items][:search].keys.include?(k)
#     params[:items][:search][k]
#   else
#     'all'
#   end
# end
#
# def format_text_tag(tag_value)
#   tag_value.underscore.split('_').join(' ').sub('one of a kind', 'One-of-a-Kind').split(' ').map{|w| w.capitalize}.join(' ')
# end
#
# def filter_keys
#   %w[medium_category medium material]
# end
