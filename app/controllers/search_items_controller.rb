class SearchItemsController < ApplicationController
  def search
    @invoice = Invoice.find(params[:invoice_id])
    #@items = Item.product_items(params[:search_items][:search])
    @items = Item.search(search_params)
    puts "#{@items}"

    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  def search_params
    h={}
    params[:search_items][:search].each do |k,v|
      h.merge!({k=>v})
    end
    h
  end
  # def search_item_params
  #   params.require(:search_item).permit!
  # end
  #
  # def search_params
  #   set=[]
  #   params[:search_items][:search].each do |k,v|
  #     #h.merge!({k=>v}) unless v.blank?
  #     set << [k,v] unless v.blank?
  #   end
  #   set
  # end
end
