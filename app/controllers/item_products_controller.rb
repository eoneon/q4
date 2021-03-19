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
    @tags = hsh_init(@item.tags)
    add_product(@product)
    @item.tags = @tags

    @item.save
  end

  def show
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @product = @item.product
    @products = Product.all
  end

  def update
    @item = Item.find(params[:id])
    @product = Product.find(params[:product_id])
    @tags, @item_groups = hsh_init(@item.tags), @item.item_groups
    replace_product(@product, @item.product)
    @item.tags = @tags

    @item.save

    # respond_to do |format|
    #   format.js
    # end
  end

  def destroy
    @item = Item.find(params[:id])
    @tags, @item_groups = hsh_init(@item.tags), @item.item_groups
    remove_product(@item.product)
    @item.tags = @tags

    @item.save
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

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end
  ##############################################################################

  def default_field(k, f_type, f_obj)
    if f_type == 'select_field'
      default_option(k, f_obj)
    elsif k == 'dimension' && f_type == 'select_menu'
      f_obj.fieldables.first
    end
  end

  def default_option(k, f_obj)
    if %w[edition material signature certificate].include?(k)
      f_obj.fieldables.first
    elsif k == 'medium'
      f_obj.fieldables.detect{|f| f_obj.field_name == compound_classify(f.field_name)}
    end
  end
end
