class InvoicesController < ApplicationController
  def show
    @invoice = Invoice.find(params[:id])
  end

  def search
    @invoice = Invoice.find(params[:id])
    @items = Item.index_hstore_input_group(Item.item_search_keys, 'csv_tags', search_results: [])
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

    if @invoice.destroy
      flash[:notice] = "\"#{@invoice.name}\" was deleted successfully."
      redirect_to @invoice.supplier
    else
      flash.now[:alert] = "There was an error deleting the invoice."
      render :show
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit!
  end

  def search_params(search_item_params)
    if search_params = params[:search]
      search_params.reject{|k,v| v.blank?}.to_a
    else
      []
    end
  end
end
