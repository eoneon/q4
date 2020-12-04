class SearchItemsController < ApplicationController
  def index
    @invoice = Invoice.find(params[:invoice_id])
    @items = Item.index_hstore_input_group(Item.item_search_keys, 'csv_tags')

    respond_to do |format|
      format.js
      format.html
    end
  end

  def search
    @invoice = Invoice.find(params[:invoice_id])
    #@items = Item.search(search_params)
    @items = Item.search(hattrs: search_params, hstore: 'csv_tags')

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
