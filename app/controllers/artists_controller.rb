class ArtistsController < ApplicationController
  def index
    @artists = Artist.all #where("tags -> 'kind' = 'medium'") #where("tags ? :key", key: "medium")
  end

  def search
    @artist = Artist.find(params[:id]) #where("tags -> 'kind' = 'medium'") #where("tags ? :key", key: "medium")

    respond_to do |format|
      format.js
    end

  end

  def create
    @artist = Artist.new(artist_params)
    @artist.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @artist = Artist.find(params[:id])
    @artist.assign_attributes(artist_params)
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
