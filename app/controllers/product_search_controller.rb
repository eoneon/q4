class ProductSearchController < ApplicationController
  def index
    @search_set = search_set
    @input_group = FieldSet.search_inputs(@search_set, selected_hsh) #puts "3 selected_hsh: #{selected_hsh}"

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_set
    if search_params
      FieldSet.kv_set_search(search_params) #puts "1 search_set: kv_set_search"
    else
      FieldSet.media_set #puts "1 search_set: media_set"
    end
  end

  def search_params
    valid_params = params[:product_search].reject {|k,v| v == 'all' || v.empty?}.each {|k,v| [k,v]} if params[:product_search].present? #puts "search_params: #{selected_hsh}"
    if valid_params && valid_params.any?
      valid_params
    end
  end

  def selected_hsh
    #tags = FieldSet.search_tags(@search_set)
    tags = FieldSet.tag_set(@search_set)
    if search_params
      params[:hidden].reject {|k,v| tags.exclude?(k)} #if params[:product_search].present?
    else
      tags.map{|tag_param| [tag_param, 'all']}.to_h
    end
  end

  # def tag_set
  #   FieldSet.search_tags(@search_set)
  # end

end
