class ItemProductsController < ApplicationController

  def create
    @item = Item.find(params[:id])
    #scopes = {product: @item.product, artist:nil}
    #Product.search(search_params(scopes, product_hattrs(scopes[:product])))
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
    #scopes = scope_params(Product.scope_keys, params)
    #Product.search(search_params(Product.scope_keys, product_hattrs(@item.product)))
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
    puts "product-search-test: #{product_search_params}"
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
