class ExportSkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    @items = @invoice.items

    respond_to do |format|
      format.csv {send_data Item.to_csv(@items.where(sku: skus)), filename: "#{@invoice.invoice_number}.csv"}
    end
  end

  private

  def skus
    format_skus(params[:skus]).uniq
  end
end

# def export_sku_params
#   params.require(:export_sku).permit!
# end

# def invalid_sku_range?(start_sku, end_sku)
#   case
#     when start_sku == 0; "First sku invalid."
#     when end_sku == 0; "Last sku invalid."
#     when start_sku >= end_sku; "Invalid sku range."
#     when start_sku.to_s.length == 6 && end_sku.to_s.length != 6; "Invalid sku range."
#   end
# end
