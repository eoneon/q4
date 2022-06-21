class ItemsController < ApplicationController

  def update
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @item.assign_attributes(item_params)
    @item.update_target_case('artist', @item.artist, params[:item][:artist_id])
    @rows = @item.update_product_case('product', @item.product, params[:item][:product_id])
    @titles = Artist.titles(@item.artist)

    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item).permit(:sku, :title, :retail, :qty)
  end

end

# def create
#   @invoice = Invoice.find(params[:invoice_id])
#   @item = @invoice.items.build(item_params)
#   @item.save
#
#   respond_to do |format|
#     format.js
#   end
# end

# def destroy
#   @item = Item.find(params[:id])
#   @invoice = @item.invoice
#
#   if @item.destroy
#     redirect_to [@invoice.supplier, @invoice]
#   else
#     flash.now[:alert] = "There was an error deleting the item."
#     render :show
#   end
# end
