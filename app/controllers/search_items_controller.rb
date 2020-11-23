class SearchItemsController < ApplicationController
  def search
    @invoice = Invoice.find(params[:invoice_id])
    @items = Item.search(search_params)

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_params
    h={}
    params[:search_items][:search].each do |k,v|
      h.merge!({k=>v})
    end
    h
  end
  
end
