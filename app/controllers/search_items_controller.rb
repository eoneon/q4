class SearchItemsController < ApplicationController
  def index
    @invoice = Invoice.find(params[:invoice_id])
    @items, @inputs = Item.item_search

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    @items, @inputs = Item.item_search

    respond_to do |format|
      format.html {render file: "/invoices/search.html.erb"}
    end
  end

  def search
    @invoice = Invoice.find(params[:invoice_id])
    @items, @inputs = Item.item_search(search_params)
    respond_to do |format|
      format.js
    end
  end

  private

  def search_params
    {product: cond_find(Product, params[:items][:product_id]),
    artist: cond_find(Artist, params[:items][:artist_id]),
    title: cond_val(params[:items][:title]),
    hattrs: params[:items][:hattrs].to_unsafe_h}
  end

end
