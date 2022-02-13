class TitlesController < ApplicationController
  def new
    @titles = titles(cond_find(Artist, params[:item][:artist_id]), cond_find(Product, params[:item][:product_id]))
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
