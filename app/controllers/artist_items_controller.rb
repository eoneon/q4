class ArtistItemsController < ApplicationController

  def search
    puts "item_search_params: #{item_search_params}"
    @item_inputs = Artist.search(item_search_params)
    @items = @item_inputs['items']
    #puts "@item_inputs['artist'] = #{@item_inputs['artist']}"
    respond_to do |format|
      format.js
    end
  end

  private

end


  # def search_params
  #   {product: cond_find(Product, params[:items][:product_id]),
  #   artist: cond_find(Artist, params[:items][:artist_id]),
  #   title: cond_val(params[:items][:title]),
  #   hattrs: params[:items][:hattrs].to_unsafe_h}
  # end
