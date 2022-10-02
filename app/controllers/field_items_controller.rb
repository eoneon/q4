class FieldItemsController < ApplicationController
  def index
    @field_items = FieldItem.all.order(:type, :kind)
    respond_to do |format|
      format.html
      format.csv { send_data @field_items.to_csv }
    end
  end

  def import
    FieldItem.import(params[:file])
    redirect_to field_items_path
    flash[:notice] = "Field items successfully imported."
  end
end
