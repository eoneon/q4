class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.all.order(supplier_name: 'asc')
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.save
    @suppliers = Supplier.all.order(supplier_name: 'asc')

    respond_to do |format|
      format.js
    end
  end

  def update
    @supplier = Supplier.find(params[:id])
    @supplier.assign_attributes(supplier_params)
    @supplier.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def supplier_params
    params.require(:supplier).permit!
  end
end
