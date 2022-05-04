class ArtistItemsController < ApplicationController

  def search
    @item_inputs = Artist.search(item_search_params)
    @items = @item_inputs[:items]

    respond_to do |format|
      format.js
    end
  end

end
