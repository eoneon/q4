class SearchItemsController < ApplicationController
  def index
    @invoice = Invoice.find(params[:invoice_id])
    @items, @input_group = Item.search

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    @items, @input_group = Item.search

    respond_to do |format|
      format.js
      format.html {render file: "/invoices/search.html.erb"}
    end
  end

  def search
    @invoice = Invoice.find(params[:invoice_id])
    @items, @input_group = Item.search(scope: artist_id, hattrs: params[:search_items][:hattrs].to_unsafe_h)
    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def artist_id
    params[:search_items][:scope].present? ? Artist.find(params[:search_items][:scope]) : nil
  end

end

# def search
#   @invoice = Invoice.find(params[:invoice_id])
#   #@items = Item.search(scope: scope_set[0], joins: scope_set[-1], hattrs: params[:search_items][:search].to_unsafe_h, attrs: params[:search_items][:attrs].to_unsafe_h, search_keys: Item.item_search_keys, sort_keys: Item.item_search_keys.append('size'), hstore: 'csv_tags')
#   @items = Item.search(scope: scope_set[0], joins: scope_set[-1], hattrs: params[:search_items][:search].to_unsafe_h, attrs: params[:search_items][:attrs].to_unsafe_h, search_keys: Item.sort_keys[0..-2], sort_keys: Item.sort_keys, hstore: 'tags')
#   respond_to do |format|
#     format.js
#     format.html
#   end
# end

# def scope_set
#   if params[:search_items][:scope].present?
#     [Artist.find(params[:search_items][:scope]), :item_groups]
#   else
#     [nil]
#   end
# end
