class SkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    format_skus(params[:item][:skus]).each do |sku|
      Item.create(sku: sku, invoice: @invoice)
    end

    respond_to do |format|
      #format.html
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
    params.require(:item).permit!
  end

  def uniq_sku?(sku)
    sku.to_s.length <= 3 && @invoice.items.pluck(:sku).exclude?(sku) || Item.all.pluck(:sku).exclude?(sku)
  end

  def format_skus(skus, set=[])
    skus.split(',').each do |sku_block|
      format_sku_block(sku_block, set)
    end
    set.flatten.uniq.sort.select{|sku| uniq_sku?(sku)}
  end

  def format_sku_block(sku_block, set)
    if sku_block.index('-')
      format_range(sku_block.split('-'), set)
    else
      format_sku(extract_digits(sku_block), set)
    end
  end

  def format_range(sku_range, set)
    sku_range = sku_range.map{|i| extract_digits(i)}.reject{|i| i.blank?}
    set << build_range(sku_range) if valid_range?(sku_range)
  end

  def build_range(sku_range)
    (sku_range[0].to_i..sku_range[1].to_i).to_a
  end

  def valid_range?(sku_range)
     sku_range.count == 2 && valid_range_format?(sku_range) && asc_range?(sku_range)
  end

  def valid_range_format?(sku_range)
    sku_range.all?{|i| i.length <= 3} || sku_range.all?{|i| i.length == 6}
  end

  def asc_range?(sku_range)
    sku_range[0].to_i < sku_range[1].to_i
  end

  def format_sku(sku, set)
    set << sku.to_i if sku.length <= 3 || sku.length == 6
  end

  def extract_digits(num_str)
    num_str.gsub(/\D/, '')
  end

end
