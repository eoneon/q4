class ProductSearchController < ApplicationController
  def index
    @search_set = search_set
    @search_inputs = FieldSet.search_inputs(@search_set, tag_params) #puts "3 tag_params: #{tag_params}"
    @selected = @search_inputs[:hidden].map {|h| ["#product_search_#{h[:field_name]}", h[:field_value].to_i]}

    # puts "4(a) hidden_inputs: #{@search_inputs[:hidden]}"
    # puts "4(b) inputs: #{@search_inputs[:inputs]}"
    # puts "5 selected: #{@selected}"

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_set
    if kv_params
      FieldSet.kv_set_search(kv_params) #puts "1 search_set: kv_set_search"
    else
      FieldSet.media_set #puts "1 search_set: media_set"
    end
  end

  def tag_params
    tags = FieldSet.tag_params(@search_set) #puts "2 tags: #{tags}"
    if kv_params
      params[:hidden].reject {|k,v| tags.exclude?(k)} #if params[:product_search].present?
    else
      tags.map{|tag_param| [tag_param, 0]}.to_h #.stringify_keys
    end
  end

  def kv_params
    search_params = params[:product_search].reject {|k,v| v.empty?}.each {|k,v| [k,v]} if params[:product_search].present? #puts "kv_params: #{search_params}"
    if search_params && search_params.any?
      search_params
    end
  end

end
