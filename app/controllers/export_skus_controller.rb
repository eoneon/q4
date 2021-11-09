class ExportSkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    @item_set = @invoice.items
    start_sku, end_sku = params[:start_sku].to_i, params[:end_sku].to_i

    if msg = invalid_sku_range?(start_sku, end_sku)
      flash[:alert] = msg
    else
      respond_to do |format|
        format.csv {send_data Item.to_csv(@item_set.where(sku: [(start_sku..end_sku)])), filename: "#{@invoice.invoice_number}.csv"}
      end
      flash[:notice] = "Skus: #{start_sku}-#{end_sku} successfully exported."
    end
  end

  private

  def export_sku_params
    params.require(:export_sku).permit!
  end

  def invalid_sku_range?(start_sku, end_sku)
    case
      when start_sku == 0; "First sku invalid."
      when end_sku == 0; "Last sku invalid."
      when start_sku >= end_sku; "Invalid sku range."
      when start_sku.to_s.length == 6 && end_sku.to_s.length != 6; "Invalid sku range."
    end
  end
end
