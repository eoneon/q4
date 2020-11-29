class SkusController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    targets = item_targets

    format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}.each do |sku|
      i = Item.create(sku: sku, qty: 1, invoice: @invoice)
      if targets
        targets['set'].map{|target| i.assoc_unless_included(target)}
        i.tags = targets['tags'] if targets['tags']
        i.csv_tags = Export.new.export_params(i, i.product, nil, i.product_group['params'] )
        i.save
      end
    end

    # format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}.each do |sku|
    #   i = Item.create(sku: sku, invoice: @invoice)
    #   if targets
    #     targets['csv_tags']['sku'] = sku
    #     targets['set'].map{|target| i.assoc_unless_included(target)}
    #     i.tags = targets['tags']
    #     i.csv_tags = targets['csv_tags']
    #     i.save
    #   end
    # end

  end

  def batch_destroy
    @invoice = Invoice.find(params[:invoice_id])
    skus = format_skus(params[:item][:skus])
    @invoice.items.where(sku: skus, invoice: @invoice).destroy_all

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
    set.flatten.uniq.sort
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

  ##############################################################################

  # def csv_tags(csv_tags)
  #   update_csv_tags(csv_tags).each do |k,v|
  #     csv_tags[k] = v
  #   end
  #   csv_tags
  # end
  #
  # def update_csv_tags(csv_tags)
  #   h = %w[title artist_name retail frame_width frame_height mounting_dimensions].map{|k| [k,nil]}.to_h
  #   h.merge([['numbering', csv_tags['edition']], ['qty', 1]].to_h)
  # end
  #
  # def tags(tags, h={})
  #   tags.each do |k,v|
  #     v = %w[material_width material_height].include?(k) ? v : nil
  #     h.merge!({k=>v})
  #   end
  #   h
  # end

  ##############################################################################

  def item_targets
    if id = params[:hidden][:item_id]
      item = Item.find(id)
      product_group = item.product_group['params']
      tags = product_group.dig('field_sets', 'dimension', 'tags')
      product_assocs(product_group , h={'set'=>[item.product], 'tags'=>tags})
    end
  end

  # def item_targets
  #   if id = params[:hidden][:item_id]
  #     item = Item.find(id)
  #     product = item.product
  #     tags, csv_tags = Export.new.update_descriptions(item.tags, item.csv_tags)
  #     product_group = item.product_group['params']
  #     product_assocs(product_group, h={'set'=>[product], 'tags'=>tags(tags), 'csv_tags'=> csv_tags(csv_tags)})
  #   end
  # end

  def product_assocs(pg_hsh, h)
    pg_hsh.each do |f_key, f_hsh|
      product_group_assocs(f_key, f_hsh, h)
      h['set'].flatten!
    end
    h
  end

  def product_group_assocs(f_key, f_hsh, h)
    if f_key == 'options'
      option_assocs(f_hsh, h['set'])
    else
      field_set_assocs(f_hsh, h)
    end
  end

  def option_assocs(f_hsh, set)
    f_hsh.values.map{|obj| assign_assocs(obj, set)}
  end

  def field_set_assocs(f_hsh, set)
    f_hsh.each do |k,k_hsh|
      select_assocs(k, k+'_id', k_hsh, set)
    end
  end

  def select_assocs(k, fk, k_hsh, h)
    [[fk], ['options', fk]].each do |keys|
      v = k_hsh.dig(*keys)
      next if v.blank?
      assign_assocs(v, h['set'])
    end
  end

  # def select_assocs(k, fk, k_hsh, h)
  #   [[fk], ['options', fk], ['tags']].each do |keys|
  #     v = k_hsh.dig(*keys)
  #     next if v.blank? || keys[0] == 'tags' && k != 'dimension'
  #     if keys[0] == 'tags'
  #       h['tags'].merge!(v)
  #     else
  #       assign_assocs(v, h['set'])
  #     end
  #   end
  # end

  def assign_assocs(obj, set)
    set << obj if obj.present?
  end

  def extract_digits(num_str)
    num_str.gsub(/\D/, '')
  end

end

# def item_targets
#   if id = params[:hidden][:item_id]
#     @item = Item.find(id)
#     @product = @item.product
#     @product_group = @item.product_group['params']
#     @artist = nil
#     product_assocs(@product_group, h={'set'=>[@product], 'tags'=>{}})
#   end
# end


  # def create
  #   @invoice = Invoice.find(params[:invoice_id])
  #   format_skus(params[:item][:skus]).select{|sku| uniq_sku?(sku)}.each do |sku|
  #     Item.create(sku: sku, invoice: @invoice)
  #   end
  #
  #   respond_to do |format|
  #     format.js
  #   end
  # end
