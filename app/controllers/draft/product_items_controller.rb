class ProductItemsController < ApplicationController
  def index
    @product_items = ProductItem.all
  end

  def show
    @product_item = ProductItem.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def create
    @product_item = ProductItem.new(product_item_params)
    @product_item.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @product_item = ProductItem.find(params[:id])
    @product_item.assign_attributes(product_item_params)
    @product_item.save

    unless target_params.empty?
      target_params.each do |target_hsh|
        assoc = target_hsh.keys.first
        @product_item.scoped_target_collection(assoc) << str_to_class(assoc).update_targets(target_hsh[assoc])
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @product_item = ProductItem.find(params[:id])

    if @product_item.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def product_item_params
    params.require(:product_item).permit(:type, :item_name, :id) #, materials_attributes: [:material_id, :item_name], mountings_attributes: [:mounting_id, :item_name]
  end

  def target_params
    set=[]
    assoc_params.map {|k| h={k => request.params[:product_item][k]}}.each do |h| #.map {|h| h[h.keys.first].delete_if {|k,v| v.blank?}} #.reject {|i| i.blank?}
      hsh={h.keys.first => h[h.keys.first].delete_if {|k,v| v.blank?}}
      set << hsh unless hsh[h.keys.first].empty?
    end
    set
  end

  def assoc_params
    @product_item.to_class.assoc_names.map{|assoc| assoc.to_sym}
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

end
