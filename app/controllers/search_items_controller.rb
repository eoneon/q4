class SearchItemsController < ApplicationController
  def search
    @invoice = Invoice.find(params[:invoice_id])
    puts "wtf params: #{params}"
    puts "search_item_params: #{search_item_params}"
    @items = Item.product_items(search_item_params)

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_item_params
    params.require(:search_item).permit! #(:sku, :title, :retail, :qty)
  end

  def search_params(search_item_params)
    if search_params = params[:search]
      search_params.reject{|k,v| v.blank?}.to_a
    else
      []
    end
  end
end
