class ItemFieldsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @item.tags = hsh_init(@item.tags)
    param_set = Item.build_params(params[:item].to_unsafe_h, :k, :t,:f_name,:f_val)
    @item.update_field(param_set, @item.input_params)
    @input_group = @item.input_group

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_fields).permit!
  end

end
