class ItemsController < ApplicationController

  def show
    @item = Item.find(params[:id])
    @product_inputs = Product.search(product_search_params(product: @item.product))
    @titles = @product_inputs[:title][:opts]
    @rows = @item.form_and_data(action: action_name)
    @hattr_rows = @item.get_hattr_form_rows(@rows, dig_keys_for_dup_form)

    respond_to do |format|
      format.js
    end
  end

  def update
    @item = Item.find(params[:id])
    @toggle = param_hsh[:card_id]
	  @rows, @titles = @item.update_item(param_hsh, item_params, dig_keys_for_param_update(param_hsh[:update_field]))
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @invoice = @item.invoice
    @item.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item).permit(:title, :retail, :qty)
  end

  def dig_keys_for_dup_form
  	[%w[dimension number_field]]
  end
end
