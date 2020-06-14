class ItemsController < ApplicationController
  def show
    @item = Item.find(params[:id])
    @search_set = search_set
    @input_group = input_group
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
    set_product
    @search_set = search_set
    @input_group = input_group


    respond_to do |format|
      format.js
    end
  end

  def search
    @search_set = search_set
    @input_group = input_group
    puts "search_set: #{@search_set}"
    puts "input_group: #{@input_group}"

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
    params.require(:item).permit!
  end

  def set_product
    if product_id = @item.product_id
      reset_product(product_id)
    else
      @product = FieldSet.find(params[:hidden][:product_id])
      @item.field_sets << @product
    end
  end

  def reset_product(product_id)
    if params[:hidden][:product_id].blank?
      destroy_assoc(product_id)
    elsif product_id != params[:hidden][:product_id]
      destroy_assoc(product_id)
      @product = FieldSet.find(params[:hidden][:product_id])
      @item.field_sets << @product unless @item.field_sets.include?(@product)
    end
  end

  def destroy_assoc(product_id)
    @item.item_groups.where(target_id: product_id).first.destroy
  end

end
