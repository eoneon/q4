class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def search_set
    case
    when action_name == "show" && @item.product then FieldSet.kv_set_search(build_kv_set(@item.product))
    when action_name == "search" then search_query
    when action_name == "update" && @product then FieldSet.kv_set_search(build_kv_set(@product))
    else FieldSet.media_set
    end
  end

  def input_group
    FieldSet.search_inputs(@search_set, selected_hsh, 'items_search')
  end

  def selected_hsh
    case
    when action_name == "show" && @item.product then build_kv_set(@item.product).to_h
    when action_name == "search" then params[:hidden][:search].reject {|k,v| search_tags.exclude?(k)}
    when action_name == "update" && @product then build_kv_set(@product).to_h
    else search_tags.map{|tag_param| [tag_param, 'all']}.to_h
    end
  end

  def build_kv_set(product)
    product.tags.keys.map {|k| [k, product.tags[k]] if filtered_tags.include?(k)}.compact
  end

  def search_query
    if valid_search = valid_search_params
      FieldSet.kv_set_search(valid_search)
    else
      FieldSet.media_set
    end
  end

  def valid_search_params
    search_params = params[:items][:search].reject {|k,v| v == 'all' || v.empty?}.each {|k,v| [k,v]}
    if search_params.any?
      search_params
    end
  end

  def search_tags
    FieldSet.filtered_tags(FieldSet.tag_set(@search_set), filtered_tags)
  end

  def filtered_tags
    %w[medium_category medium material]
  end

  def format_params(param_hsh, v2='all')
    param_hsh.reject {|k,v| v == v2 || v.empty?}.each {|k,v| [k,v]}
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  ##############################################################################

  def update_assocs(origin, target, params_target_id)
    if target.present? && params_target_id.blank?
      remove_assoc(origin, target)
    elsif target.present? && (params_target_id != target.id)
      replace_assoc(origin, target, params_target_id)
    elsif target.blank? && params_target_id.present?
      add_assoc(origin, target, params_target_id)
    end
  end

  def remove_assoc(origin, target)
    puts "1 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    origin.item_groups.where(target_id: target.id).first.destroy
    target = nil
    a, b = origin, target
  end

  def replace_assoc(origin, target, params_target_id)
    puts "2 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    remove_assoc(origin, target)
    add_assoc(origin, target, params_target_id)
    a, b = origin, target
  end

  def add_assoc(origin, target, params_target_id)
    puts "3 item: #{@item}, target: #{@item.product}, params_id: #{params[:hidden][:product_id]}"
    target = target.to_class.find(params_target_id)
    origin.assoc_unless_included(target)
    a, b = origin, target
  end
end
