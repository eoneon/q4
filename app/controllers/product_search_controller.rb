class ProductSearchController < ApplicationController
  def index
    @search_set = search_set
    @input_group = FieldSet.search_inputs(@search_set, selected_hsh)

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_set
    if search_params
      FieldSet.kv_set_search(search_params)
    else
      FieldSet.media_set
    end
  end

  def search_params
    valid_params = params[:product_search].reject {|k,v| v == 'all' || v.empty?}.each {|k,v| [k,v]} if params[:product_search].present?
    puts "valid_params: #{valid_params}"
    if valid_params && valid_params.any?
      valid_params
    end
  end

  def selected_hsh
    tags = FieldSet.tag_set(@search_set)
    if search_params
      params[:hidden].reject {|k,v| tags.exclude?(k)}
    else
      tags.map{|tag_param| [tag_param, 'all']}.to_h
    end
  end

end
