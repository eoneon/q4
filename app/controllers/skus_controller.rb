class SkusController < ApplicationController

  def search
    @invoice = Invoice.find(params[:invoice_id])
    product = cond_find(Product, params[:item][:product])
    artist_id = cond_id(params[:item][:artist])
    @results, @inputs = Product.invoice_search(product: product, artist_id: artist_id, hattrs: params[:items][:hattrs].to_unsafe_h)

    respond_to do |format|
      format.js
    end
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    artist = cond_find(Artist, params[:item][:artist_id])
    product = cond_find(Product, params[:item][:product_id])
    Item.new.batch_create_skus(@invoice, product, product_args(product), artist, skus) if skus
    @results, @inputs = Product.invoice_search

    respond_to do |format|
      format.js
    end
  end

  def batch_destroy
    @invoice = Invoice.find(params[:invoice_id])
    skus = format_skus(params[:item][:skus])
    @invoice.items.where(sku: skus, invoice: @invoice).destroy_all

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

  def titles(artist, product)
    artist ? artist.titles(product) : []
  end

  def cond_find(klass, param_val)
    klass.find(param_val) unless param_val.blank?
  end

  def cond_id(fk_id)
    fk_id ? fk_id : nil
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
