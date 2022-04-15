class TitlesController < ApplicationController
  def new
    @titles = Artist.titles(cond_find(Artist, params[:item][:artist_id]))
    @target = params[:item][:context]

    respond_to do |format|
      format.js
    end
  end

  private

  def title_params
    params.require(:item).permit!
  end
end
