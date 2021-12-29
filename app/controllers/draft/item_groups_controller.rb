class ItemGroupsController < ApplicationController
  def sort_up
    @item_group = ItemGroup.find(params[:id])
    @origin = @item_group.origin
    swap_sort(-1)

    respond_to do |format|
      @obj_ref = params[:obj_ref]
      format.js
    end
  end

  def sort_down
    @item_group = ItemGroup.find(params[:id])
    @origin = @item_group.origin
    swap_sort(1)

    respond_to do |format|
      format.js
    end
  end

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

  def swap_sort(pos)
    sort = @item_group.sort
    sort2 = pos == -1 ? sort - 1 : sort + 1

    sort_obj2 = @origin.item_groups.where(sort: sort2)
    sort_obj2.update(sort: sort)
    @item_group.update(sort: sort2)
  end
end
