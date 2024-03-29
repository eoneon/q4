class TableSkusController < ApplicationController

  def show
    @item = Item.find(params[:id])
    @product_inputs = Product.search(product_search_params(product: @item.product))
    @titles = @product_inputs[:title][:opts]
    @rows, attrs = @item.form_and_data(action: action_name)
    @hattr_rows = @item.get_hattr_form_rows(@rows, dig_keys_for_dup_form)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @invoice = @item.invoice
    @item.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def sku_params
    params.require(:item).permit!
  end

  def dig_keys_for_dup_form
  	[%w[dimension number_field]]
  end
end





















# def update
#   @invoice = Invoice.find(params[:invoice_id])
#   @item = Item.find(params[:id])
#   @item.assign_attributes(item_params)
#   @titles = titles(cond_find(Artist, params[:item][:artist_id]))
#
#   @item.update_target_case('artist', @item.artist, params[:item][:artist_id])
#   @item.update_product_case('product', @item.product, params[:item][:product_id])
#   #@product_inputs = Product.psearch(product_search_params(product: @item.product))
#
#   @rows, attrs = @item.input_group
#   @item.update_csv_tags(attrs)
#
#   @item.save
#
#   respond_to do |format|
#     format.js
#   end
# end

# def item_params
#   {title: cond_val(params[:item][:title]), retail: cond_val(params[:item][:retail]), qty: cond_val(params[:item][:qty]), invoice: @invoice}.reject{|k,v| v.blank?}
# end
#
# def product_args(product)
#   product.f_args(product.g_hsh) if product
# end
#
# def skus
#   format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}
# end
#
# def uniq_sku?(sku)
#   sku.to_s.length <= 3 && @invoice.items.pluck(:sku).exclude?(sku) || Item.all.pluck(:sku).exclude?(sku)
# end
