class ProductsController < ApplicationController
  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def create
    @product = Product.new(product_params)
    @product.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @product = Product.find(params[:id])
    @product.assign_attributes(product_params)
    @product.save

    unless target_params.empty?
      target_params.each do |target_hsh|
        assoc = target_hsh.keys.first
        @product.scoped_target_collection(assoc) << str_to_class(assoc).update_targets(target_hsh[assoc])
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @product = Product.find(params[:id])

    if @product.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def product_params
    params.require(:product).permit(:type, :product_name, :id)
  end

  def target_params
    set=[]
    assoc_params.map {|k| h={k => request.params[:product][k]}}.each do |h| 
      hsh={h.keys.first => h[h.keys.first].delete_if {|k,v| v.blank?}}
      set << hsh unless hsh[h.keys.first].empty?
    end
    set
  end

  def assoc_params
    @product.to_class.assoc_names.map{|assoc| assoc.to_sym}
  end

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end
end
