class ItemsController < ApplicationController

  def show
    @item = Item.find(params[:id])
    @product = @item.product
    @artist = @item.artist

    @products = products
    @input_group = search_input_group
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    @item = @invoice.items.build(item_params)
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @invoice = Invoice.find(params[:invoice_id])
    @item = Item.find(params[:id])
    @item.assign_attributes(item_params)

    @item, @product = update_assocs(@item, @item.product, params[:hidden][:type], params[:hidden][:product_id])
    @item, @artist = update_assocs(@item, @item.artist, 'Artist', params[:hidden][:artist_id])

    @products = products
    @input_group = search_input_group
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def search
    @item = item
    @product = product
    @products = products
    @input_group = search_input_group

    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @invoice = @item.invoice

    if @item.destroy
      flash[:notice] = "Item was deleted successfully."
      redirect_to [@invoice.supplier, @invoice]
    else
      flash.now[:alert] = "There was an error deleting the item."
      render :show
    end
  end

  private

  def item_params
    params.require(:item).permit(:sku)
  end

  def product
    Product.find(params[:hidden][:search][:product_id]) if !params[:hidden][:search][:product_id].blank?
  end

  def item
    Item.find(params[:hidden][:search][:item_id]) if params[:hidden][:search][:item_id]
  end

  # def update_product
  #   #@product = @item.product
  #   @artist = @item.artist
  #   #set_product
  #   @item, @product = update_assocs(@item, @item.product, params[:hidden][:type], params[:hidden][:product_id])
  #   set_artist
  #   @products = products
  #   @input_group = search_input_group
  #   puts "@product: #{@product.try(:id)}"
  # end

  def set_artist
    if @artist.present? && params[:hidden][:artist_id].blank?
      destroy_assoc(@artist.id)
      @artist = nil
    elsif @artist.present? && (params[:hidden][:artist_id] != @artist.id)
      #puts "#{@artist.present? == (params[:hidden][:artist_id] != @artist.id)}"
      destroy_assoc(@artist.id)
      @artist = Artist.find(params[:hidden][:artist_id])
      @item.artists << @artist unless @item.artists.include?(@artist)
    elsif @artist.blank? && params[:hidden][:artist_id].present?
      @artist = Artist.find(params[:hidden][:artist_id])
      @item.artists << @artist
    end
  end

  def destroy_assoc(assoc_id)
    @item.item_groups.where(target_id: assoc_id).first.destroy
  end

end

# def set_product
#   if @product.present? && params[:hidden][:product_id].blank?
#     destroy_assoc(@product.id)
#     @product = nil
#   elsif @product.present? && (params[:hidden][:product_id] != @product.id)
#     destroy_assoc(@product.id)
#     @product = FieldSet.find(params[:hidden][:product_id])
#     @item.field_sets << @product unless @item.field_sets.include?(@product)
#   elsif @product.blank? && params[:hidden][:product_id].present?
#     @product = FieldSet.find(params[:hidden][:product_id])
#     @item.field_sets << @product
#   end
# end
