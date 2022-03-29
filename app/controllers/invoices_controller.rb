class InvoicesController < ApplicationController

  def index
    @invoices = Invoice.all.order(invoice_number: 'desc')
  end

  def show
    @invoice = Invoice.find(params[:id])
    @product_inputs = Product.search(product_search_params)
    @item_inputs = Item.search(item_search_params)
  end

  def new
    @supplier = Supplier.find(params[:supplier_id])
    @invoice = Invoice.new
  end

  def create
    @supplier = Supplier.find(params[:supplier_id])
    @invoice = @supplier.invoices.build(invoice_params)
    @invoice.save

    respond_to do |format|
      format.js
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.assign_attributes(invoice_params)
    @invoice.save

    respond_to do |format|
      format.js
    end

  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @supplier = @invoice.supplier

    if @invoice.destroy
      redirect_to @supplier
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit!
  end

end
