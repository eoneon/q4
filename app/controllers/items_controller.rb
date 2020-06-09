class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
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
    @item = Item.find(params[:id])
    @item.assign_attributes(item_params)
    #item_product(@item.element_id("kind", "product"), params[:product_id])

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
    params.require(:item).permit!
  end

  # def item_product(product_id, params_product_id)
  #   if params_product_id.to_i == product_id.to_i
  #     @item.save
  #   elsif params_product_id.present? && product_id.blank?
  #     @item.elements << Element.find(params_product_id)
  #   elsif params_product_id.blank? && product_id.present?
  #     @item.elements.destroy(Element.find(product_id))
  #   elsif params_product_id.present? && product_id.present?
  #     @item.elements.destroy(Element.find(product_id))
  #     @item.elements << Element.find(params_product_id)
  #   end
  # end
end
