class ProductTargetsController < ApplicationController
  def destroy
    target = params[:target]
    @target = target.constantize.find(params[:id])
    @product_item = ProductItem.find(params[:product_item_id])
    puts "product_item: #{@product_item}, target: #{target}, collection: #{@product_item.scoped_target_collection(target.downcase.pluralize)}"
    @product_item.scoped_target_collection(params[:target].downcase.pluralize).delete(target.constantize.find(params[:id]))

    respond_to do |format|
      format.js
    end
  end

  private

  def product_target_params
    params.require(:product_target).permit!
  end
end
