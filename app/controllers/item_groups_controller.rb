class ItemGroupsController < ApplicationController
  def destroy
    @item_group = ItemGroup.find(params[:id])
    @product_item = ProductItem.find(@item_group.origin_id)
    @item_group.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def product_target_params
    params.require(:item_group).permit(:id, :sort)
  end
end
