class SearchItemsController < ApplicationController
  def index
    @invoice = Invoice.find(params[:invoice_id])
    @items = Item.index_hstore_query(Item.item_search_keys, 'csv_tags')
    # default_params = Item.index_search
    # opt_set = Item.where("csv_tags?& ARRAY[:keys]", keys: default_params.keys)
    # @items = {'inputs' => Item.search_options(opt_set, default_params, 'csv_tags'), 'search_results' => Item.distinct_hstore(opt_set)}

    respond_to do |format|
      format.js
      format.html
    end
  end

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
