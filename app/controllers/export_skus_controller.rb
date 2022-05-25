class ExportSkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    @items = @invoice.items

    respond_to do |format|
      format.csv {send_data Item.to_csv(@items.where(sku: skus).order(:sku)), filename: "#{@invoice.invoice_number}.csv"}
    end
  end

  private

  def skus
    format_skus(params[:skus]).uniq
  end
end
