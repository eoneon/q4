class ProductsController < ApplicationController
  def index
    @products = Product.all.order(:product_name)
    respond_to do |format|
      format.html
      format.csv { send_data @products.to_csv }
    end
  end

  def import
    Product.import(params[:file])
    redirect_to products_path
  end
end
