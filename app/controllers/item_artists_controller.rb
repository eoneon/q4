class ItemArtistsController < ApplicationController

  def search
    @items, @item_inputs = Item.item_search(search_params)

    respond_to do |format|
      format.js
    end
  end
  # def update
  #   @item = Item.find(params[:id])
  #   @item.update_target_case('artist', @item.artist, params[:item][:artist_id])
  #   @item.save
  #
  #   respond_to do |format|
  #     format.js
  #   end
  # end

  private

  def search_params
    {product: cond_find(Product, params[:items][:product_id]),
    artist: cond_find(Artist, params[:items][:artist_id]),
    title: cond_val(params[:items][:title]),
    hattrs: params[:items][:hattrs].to_unsafe_h}
  end

end
