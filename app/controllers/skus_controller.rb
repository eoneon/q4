class SkusController < ApplicationController
  #moved to: TableSkusController
  def show
    @item = Item.find(params[:id])
    @products, @inputs = Product.search(scope: @item.product)
    @titles = titles(@item.artist)
    @rows, attrs = @item.input_group

    respond_to do |format|
      format.js
    end
  end

  def search
    @invoice = Invoice.find(params[:invoice_id])
    product = cond_find(Product, params[:item][:product_id])
    artist_id = cond_id(params[:item][:artist_id])
    #@results, @inputs = Product.invoice_search(product: product, artist_id: artist_id, hattrs: params[:items][:hattrs].to_unsafe_h)
    @nav_products, @nav_search_inputs = Product.invoice_search(product: product, artist_id: artist_id, hattrs: params[:items][:hattrs].to_unsafe_h)
    # puts "@nav_products: #{@nav_products}"
    # puts "@nav_search_inputs: #{@nav_search_inputs}"
    #
    # respond_to do |format|
    #   format.js
    # end
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    artist = cond_find(Artist, params[:item][:artist_id])
    product = cond_find(Product, params[:item][:product_id])
    Item.new.batch_create_skus(skus, item_params, artist, product, product_args(product)) if skus
    #@results, @inputs = Product.invoice_search
    @nav_products, @nav_search_inputs = Product.invoice_search

    respond_to do |format|
      format.js
    end
  end

  def update
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @item.assign_attributes(sku_params)
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def batch_destroy
    @invoice = Invoice.find(params[:invoice_id])
    @skus = format_skus(params[:item][:skus])
    @invoice.items.where(sku: @skus, invoice: @invoice).destroy_all

    respond_to do |format|
      format.js
    end
  end

  private

  def sku_params
    params.require(:item).permit!
  end

  def item_params
    {title: cond_val(params[:item][:title]), retail: cond_val(params[:item][:retail]), qty: cond_val(params[:item][:qty]), invoice: @invoice}.reject{|k,v| v.blank?}
  end

  def product_args(product)
    product.f_args(product.g_hsh) if product
  end

  def skus
    format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}
  end

  def uniq_sku?(sku)
    sku.to_s.length <= 3 && @invoice.items.pluck(:sku).exclude?(sku) || Item.all.pluck(:sku).exclude?(sku)
  end

end
