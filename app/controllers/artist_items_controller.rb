class ArtistItemsController < ApplicationController
  def search
    @item_inputs = Item.search(artist_search_params(artist: cond_find(Artist, params[:items][:artist_id])))

    respond_to do |format|
      format.js
    end
  end

  private

  def search_params
    {product: cond_find(Product, params[:items][:product_id]),
    artist: cond_find(Artist, params[:items][:artist_id]),
    title: cond_val(params[:items][:title]),
    hattrs: params[:items][:hattrs].to_unsafe_h}
  end
end
