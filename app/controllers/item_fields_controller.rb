class ItemFieldsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @toggle = params[:card_id]
    @rows = @item.update_field(dig_keys_for_param_update(param_hsh[:update_field]), param_hsh)
    @titles = Artist.titles(@item.artist)

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_fields).permit!
  end

end
