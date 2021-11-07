class ItemProductsController < ApplicationController

  def create
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @products, @inputs = Product.search(scope: @product)
    @item.add_product(@product)
    @rows, attrs = @item.input_group
    @item.update_csv_tags(attrs)

    respond_to do |format|
      format.js
    end
  end

  def update
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @products, @inputs = Product.search(scope: @product)
    @item.replace_product(@product, @item.product)
    @rows, attrs = @item.input_group
    @item.update_csv_tags(attrs)

    respond_to do |format|
      format.js
    end
  end

  def search
    @item = Item.find(params[:id])
    @products, @inputs = Product.search(scope: @item.product, hattrs: params[:items][:search].to_unsafe_h)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @products, @inputs = Product.search
    @item.remove_product(@item.product)
    @rows, attrs = @item.input_group

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_products).permit!
  end

end
