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
  	Item.find(params[:item_id]).batch_dup_skus(skus, item_params, cond_find(Artist, params[:item][:artist_id])) if skus
  	@item_inputs = Item.search(item_search_params)

  	respond_to do |format|
  			format.js
  	end
  end

  private

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
