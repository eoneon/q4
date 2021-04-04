class ItemFieldsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @item.tags = hsh_init(@item.tags)
    @item.update_field(param_set)

    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_fields).permit!
    #params.require(:item).permit(:product)
  end

  ##############################################################################

  def param_set(a=[])
    params[:item].each do |k, field_groups|
      field_groups.each do |t, fields|
        fields.each do |f_name, f_val|
          a.append({k: k, t: t, f_name: f_name, f_val: f_val})
        end
      end
    end
    a
  end

end
