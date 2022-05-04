class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
  end

  def show
    @artist = Artist.find(params[:id])
  end

  def search
    @artist = Artist.find(params[:id])
    store_hsh = filter_h(Item.scope_keys)
    store_hsh['artist_id'] = params[:id]
    @item_inputs = Item.search(item_search_params(store: store_hsh))
    @item_inputs[:artist][:opts] = [@artist]
    @items = @item_inputs[:items]

    respond_to do |format|
      format.js
    end

  end

  def create
    @artist = Artist.new(artist_params)
    @artist.sort_name
    @artist.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @artist = Artist.find(params[:id])
    @artist.assign_attributes(artist_params)
    @artist.sort_name
    @artist.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @artist = Artist.find(params[:id])

    if @artist.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def artist_params
    params.require(:artist).permit!
  end
end
