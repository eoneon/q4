class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
    @search_set = search_set
    @input_group = input_group
    @product = @item.product
    @artist = @item.artist
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
    update_product
    @item.save

    respond_to do |format|
      format.js
    end
  end

  def search
    @search_set = search_set
    @input_group = input_group

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

  def update_product
    @product = @item.product
    @artist = @item.artist
    set_product
    #@item, @product = update_assocs(@item, @item.product, params[:hidden][:product_id])
    set_artist
    @search_set = search_set
    @input_group = input_group
  end

  def format_target(target)
    target.nil? ? :field_set : target
  end

  def set_product
    if @product.present? && params[:hidden][:product_id].blank?
      destroy_assoc(@product.id)
      @product = nil
    elsif @product.present? && (params[:hidden][:product_id] != @product.id)
      destroy_assoc(@product.id)
      @product = FieldSet.find(params[:hidden][:product_id])
      @item.field_sets << @product unless @item.field_sets.include?(@product)
    elsif @product.blank? && params[:hidden][:product_id].present?
      @product = FieldSet.find(params[:hidden][:product_id])
      @item.field_sets << @product
    end
  end

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
