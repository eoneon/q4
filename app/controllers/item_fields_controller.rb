class ItemFieldsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @toggle = params[:card_id]
    @rows, @titles = @item.update_item(param_hsh, item_params, dig_keys_for_param_update(param_hsh[:update_field]))

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    {} 
  end

end
