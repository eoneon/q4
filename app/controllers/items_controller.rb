class ItemsController < ApplicationController

  def show
    @item = Item.find(params[:id])
    @products, @inputs = Product.search(scope: @item.product)
    @rows, attrs = @item.input_group
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    @item = @invoice.items.build(item_params)
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @item.assign_attributes(item_params)
    @item.update_target_case('artist', @item.artist, params[:item][:artist_id])
    @item.update_product_case('product', @item.product, params[:item][:product_id])
    @products, @inputs = Product.search(scope: @item.product)
    @rows, attrs = @item.input_group
    @item.update_csv_tags(attrs)

    @item.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @invoice = @item.invoice

    if @item.destroy
      flash[:notice] = "Item was deleted successfully."
      redirect_to [@invoice.supplier, @invoice]
    else
      flash.now[:alert] = "There was an error deleting the item."
      render :show
    end
  end

  private

  def item_params
    params.require(:item).permit(:sku, :title, :retail, :qty)
  end

end
