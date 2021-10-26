class ItemProductsController < ApplicationController

  def create
    @item = Item.find(params[:id])
    @item.tags = hsh_init(@item.tags)
    @product = Product.find(params[:product_id])
    @products, @inputs = Product.search(scope: @product)
    add_product(@product)

    @item.save
    @input_group = @item.input_group

    respond_to do |format|
      format.js
    end
  end

  def update
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @products, @inputs = Product.search(scope: @product)
    replace_product(@product, @item.product)

    @item.save
    @input_group = @item.input_group

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
    remove_product(@item.product)

    @item.save
    @input_group = @item.input_group

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_products).permit!
  end

  def add_product(product)
    @item.add_obj(product)
    @item.tags = hsh_init(@item.tags)
    @item.add_default_fields(product.f_args(product.g_hsh))
  end

  def remove_product(product)
    @item.remove_fieldables
    @item.remove_obj(product)
  end

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end

end
