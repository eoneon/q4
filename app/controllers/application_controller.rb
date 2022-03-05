class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def hsh_init(tags)
    tags ? tags : {}
  end

  def cond_find(klass, param_val)
    klass.find(param_val) unless param_val.blank?
  end

  def cond_id(fk_id)
    fk_id ? fk_id : nil
  end

  def cond_val(val, default=nil)
    val ? val : default
  end

  def titles(artist=nil, product=nil)
    artist ? artist.titles(product) : []
  end

  #search ######################
  def search_params(scope_params)
    {scopes: scope_params, hattrs: scoped_hattr_params(scope_params[:product], params[:items][:hattrs].to_unsafe_h)}
  end

  #scope ######################
  def scope_params
    [:product_id, :artist_id, :title].each_with_object({}) do |k,hsh|
      next if k==:title && !params[:item].has_key?(k)
      hsh.merge!(cond_search_param(k.to_s.split('_')[0], params[:item][k]))
    end
  end

  def cond_search_param(k, v)
    {k.to_sym => (%w[product artist].include?(k) ? cond_find(k.to_s.classify.constantize, v) : v)}
  end

  #hattr ######################
  # def hattr_search_params(product, hattrs)
  #   product ? product_hattr_params(product, hattrs.keys) : hattrs
  # end
  
  def hattr_params(args, hattrs)
    args.each_with_object({}) {|(k,keys), h| h[k] = filter_h(keys, hattrs)}
  end

  def scoped_hattr_params(product, hattrs)
    product ? filter_h(hattrs.keys, product.tags) : hattrs
  end

  # def product_hattr_params(product, search_keys)
  #   search_keys.each_with_object({}){|k,h| h[k] = product.tags.dig(k)}
  # end

  def filter_h(keys, hattrs={})
    keys.each_with_object(hattrs) {|k,hattrs| hattrs[k] = hattrs.dig(k)}
  end
  #######################
  ############################################################################

  def format_skus(skus)
    skus.split(',').each_with_object([]) {|sku_block, skus| format_sku_block(sku_block, skus)}
  end

  def format_sku_block(sku_block, skus)
    if sku_block.index('-')
      format_range(extract_range(sku_block), skus)
    else
      format_sku(extract_digits(sku_block), skus)
    end
  end

  def format_range(sku_range, skus)
    if valid_range?(sku_range)
      build_range(sku_range).map{|sku| skus.append(sku)}
    end
  end

  def extract_range(sku_block)
    sku_block.split('-').map{|sku| extract_digits(sku)}.reject{|sku| sku.blank?}
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

  def format_sku(sku, skus)
    skus << sku.to_i if sku.length <= 3 || sku.length == 6
  end

  def extract_digits(num_str)
    num_str.gsub(/\D/, '')
  end
end
