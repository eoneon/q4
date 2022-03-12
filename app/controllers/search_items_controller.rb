class SearchItemsController < ApplicationController

  def new
    @invoice = Invoice.find(params[:invoice_id])
    puts "SearchItemsController: #{search_params(Item.scope_keys, product_and_item_hattrs)}"
    #Item.search(search_params(Item.scope_keys, product_and_item_hattrs))
    @items, @inputs = Item.item_search
  end

  def search
    @invoice = Invoice.find(params[:invoice_id])
    scope_params = scope_params(Item.scope_keys, hattr_params[:item])
    puts "SearchItemsControllerTest:#{search_params(scope_params, product_and_item_hattrs(scope_params[:product], params[:items][:hattrs].to_unsafe_h))}"
    #Item.search(search_params(scope_params, product_and_item_hattrs(scope_params[:product], params[:items][:hattrs].to_unsafe_h)))
    @items, @inputs = Item.item_search(search_param)

    respond_to do |format|
      format.js
    end
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    item = Item.find(params[:item_id])
    # Product.search(search_params(Product.scope_keys, product_hattrs))
    artist = cond_find(Artist, params[:item][:artist_id])
    item.batch_dup_skus(skus, item_params, artist) if skus
    @results, @inputs = Product.invoice_search
  end

  private

  def search_param
    {product: cond_find(Product, params[:items][:product_id]),
    artist: cond_find(Artist, params[:items][:artist_id]),
    title: cond_val(params[:items][:title]),
    hattrs: params[:items][:hattrs].to_unsafe_h}
  end

  def item_params
    {title: cond_val(params[:item][:title]), retail: cond_val(params[:item][:retail]), qty: cond_val(params[:item][:qty]), invoice: @invoice}.reject{|k,v| v.blank?}
  end

  def skus
    format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}
  end

  def uniq_sku?(sku)
    sku.to_s.length <= 3 && @invoice.items.pluck(:sku).exclude?(sku) || Item.all.pluck(:sku).exclude?(sku)
  end

end


# respond_to do |format|
#   #format.html {render file: "/invoices/search.html.erb"}
#   format.html {render file: "/search_items/show.html.erb"}
# end

#redirect_to "/supplier/#{@invoice.supplier.id}/invoices/#{@invoice.id}"
#back #[@invoice.supplier, @invoice]

# respond_to do |format|
#   format.html {render "/supplier/#{@invoice.supplier.id}/invoices/#{@invoice.id}"}
# end

# def index
#   @invoice = Invoice.find(params[:invoice_id])
#   @items, @inputs = Item.item_search
#
#   respond_to do |format|
#     format.js
#     format.html
#   end
# end
