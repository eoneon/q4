class ItemsController < ApplicationController

  def update
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @item.update_item(assoc_params, item_params)
    @rows = @item.assign_cvtags_with_rows(@item.form_and_data)
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

  def assoc_params
    param_hsh['item'].select {|param_key, param_val| param_key.split('_')[-1]=='id'}.transform_keys {|param_key|  param_key.sub('_id', '')}
  end
end
