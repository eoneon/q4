class SkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])

    (params[:start_sku]..params[:end_sku]).each do |sku|
      item = Item.create(sku: sku, invoice: @invoice)
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @invoice = Invoice.find(params[:invoice_id])
    @invoice.items.where(sku: (params[:start_sku]..params[:end_sku])).destroy_all

    respond_to do |format|
      format.js
    end
  end

  private

  def sku_params
    params.require(:sku).permit!
  end
end
