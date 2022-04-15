class BatchItemsController < ApplicationController

  def search
    @invoice = Invoice.find(params[:invoice_id])
    @item_inputs = Item.search(item_search_params)

    respond_to do |format|
      format.js
    end
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    item = Item.find(params[:item_id])
    artist = cond_find(Artist, params[:item][:artist_id])
    item.batch_dup_skus(skus, item_params, artist) if skus
    @item_inputs = Item.search(item_search_params)

    respond_to do |format|
      format.js
    end
  end

  private

  # def search_param
  #   {product: cond_find(Product, params[:items][:product_id]),
  #   artist: cond_find(Artist, params[:items][:artist_id]),
  #   title: cond_val(params[:items][:title]),
  #   hattrs: params[:items][:hattrs].to_unsafe_h}
  # end

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
