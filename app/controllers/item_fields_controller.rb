class ItemFieldsController < ApplicationController

  def update
    @item = Item.find(params[:id])
    @item.tags = hsh_init(@item.tags)
    param_set = Item.build_params(params[:item].to_unsafe_h, :k, :t,:f_name,:f_val)
    @item.update_field(param_set)

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_fields).permit!
  end

end

# def param_set
#   params[:item].to_unsafe_h.each_with_object([]) do |(k, field_groups),a|
#     field_groups.each do |t, fields|
#       fields.each do |f_name, f_val|
#         a.append({k: k, t: t, f_name: f_name, f_val: f_val})
#       end
#     end
#   end
# end
