class ItemProductsController < ApplicationController
  # def index
  #   @item = Item.find(params[:id])
  #   @product = @item.product
  #   @artist = @item.artist
  #   @products = Product.all
  # end

  def create
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @products = Product.all
    @tags = hsh_init(@item.tags)
    add_product(@product)
    @item.tags = @tags

    @item.save

    respond_to do |format|
      format.js
    end
  end

  # def show
  #   @invoice = Invoice.find(params[:invoice_id])
  #   @item = Item.find(params[:id])
  #   @product = @item.product
  #   @products = Product.all
  # end

  def update
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @products = Product.all
    @tags, @item_groups = hsh_init(@item.tags), @item.item_groups
    #@tags, @item_groups, @input_params = hsh_init(@item.tags), @item.item_groups, @item.input_params
    replace_product(@product, @item.product)
    @item.tags = @tags

    @item.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @products = Product.all
    @tags, @item_groups = hsh_init(@item.tags), @item.item_groups
    #@tags, @item_groups, @input_params = hsh_init(@item.tags), @item.item_groups, @item.input_params
    remove_product(@item.product)
    @item.tags = @tags

    @item.save

    respond_to do |format|
      format.js
    end
  end

  private

  def item_params
    params.require(:item_products).permit!
    #params.require(:item).permit(:product)
  end

  ##############################################################################
  def add_product(product)
    add_obj(product)
    cascade_add(product.param_args(field_groups: product.g_hsh, unpack: true))
  end

  def remove_product(product)
    cascade_remove(@item.param_args(field_groups: @item.input_params)) if @item_groups.any?
    remove_obj(product)
  end

  def cascade_remove(param_args)
    param_args.each do |f_hsh|
      remove_param(f_hsh[:t], f_hsh[:f_name], f_hsh[:f_obj])
      #remove_param(f_hsh[:t], f_hsh[:t_type], f_hsh[:f_name], f_hsh[:f_obj])
    end
  end

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end

end
