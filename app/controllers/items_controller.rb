class ItemsController < ApplicationController
  #after_action :product_group, only: [:show, :new, :create]

  def show
    @item = Item.find(params[:id])
    @product = @item.product
    @artist = @item.artist

    @products = products
    @input_group = search_input_group
    @product_group = @item.product_group
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
    #puts "item_params: #{item_params}"
    @item.assign_attributes(item_params)

    @item, @product = update_assocs(@item, @item.product, params[:hidden][:type], params[:hidden][:product_id])
    update_product
    @item, @artist = update_assocs(@item, @item.artist, 'Artist', params[:hidden][:artist_id])

    @products = products
    @input_group = search_input_group

    @item.save
    @product_group = @item.product_group

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
    params.require(:item).permit(:sku, :title, :retail, :qty)
    #params.require(:item).permit(:sku, :title, :retail, :qty, {tags: :disclaimer})
    #hsh['tags'] = hsh[:tags].to_h
    #hsh
    #item_params = params.require(:item).permit(:sku, :title, :retail, :qty, {tags: :disclaimer})
    #tags = params[:item].delete(:tags)
    #item_params[:item][:tags] = tags.to_h
    # puts tags: "#{tags}"
    # params.require(:item).permit(:sku, :title, :retail, :qty).tap do |whitelisted|
    #   whitelisted[:tags] = tags
    # end
  end

  def product
    Product.find(params[:hidden][:search][:product_id]) if !params[:hidden][:search][:product_id].blank?
  end

  def item
    Item.find(params[:hidden][:search][:item_id]) if params[:hidden][:search][:item_id]
  end

end

#params.require(:item).permit!
