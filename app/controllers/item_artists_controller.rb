class ItemArtistsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @item.update_target_case('artist', @item.artist, params[:item][:artist_id])
    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_artists).permit!
  end

end
