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
  def item_search_params(store: param_hsh, scope_keys: Item.scope_keys, product: nil)
    search_params, new_item_hsh = product_search_params(store: store, scope_keys: scope_keys, product: product), filter_h(Item.hattr_keys)
    search_params[:item_hattrs] = (product ? update_default_hsh_from_old_hsh(new_item_hsh.keys, new_item_hsh, store) : new_item_hsh)
    search_params
  end

  def product_search_params(store: param_hsh, scope_keys: Product.scope_keys, product:nil)
    new_scope_hsh, new_product_hsh = filter_h(scope_keys), filter_h(product_keys)
    scope_hsh = product ? scopes_from_product(product, new_scope_hsh) : scopes_from_params(new_scope_hsh.keys, new_scope_hsh, store)
    {scopes: scope_hsh, product_hattrs: update_default_hsh_from_old_hsh(new_product_hsh.keys, new_product_hsh, (scope_hsh[:product] ? scope_hsh[:product].tags : store))}
  end

  def scopes_from_product(product, new_scope_hsh)
    scopes = scope_hsh(new_scope_hsh)
    scopes[:product] = product
    scopes
  end

  def scopes_from_params(scope_keys, new_scope_hsh, store_hsh)
    scopes = update_default_hsh_from_old_hsh(new_scope_hsh.keys, new_scope_hsh, store_hsh)
    scopes = scope_hsh(scopes)
    puts "scopes: #{scopes}"
    scopes
  end

  def scope_hsh(scope_hsh)
    scope_hsh.each_with_object({}) do |(k,v),hsh|
      hsh.merge!(cond_search_param(k.split('_')[0], (k.split('_')[1]=='id'), v))
    end
  end

  #remove and use as class method from Hashables
  def update_default_hsh_from_old_hsh(required_keys, default_hsh, store_hsh)
    return default_hsh if required_keys.empty?
    store_hsh.each_with_object(default_hsh) do |(k,v), default_hsh|
      if v.is_a? Hash
        update_default_hsh_from_old_hsh(required_keys, default_hsh, v)
      elsif required_keys.include?(k)
        required_keys.delete(k)
        store_hsh.delete(k)
        default_hsh[k] = v if !v.blank?
      end
    end
  end

  def param_hsh
    params.to_unsafe_h.reject{|k,v| %w[utf8 controller action].include?(k)}
  end

  #remove: replaced by scope_hsh
  def scope_params(scope_keys, scope_attrs={})
    scope_keys.each_with_object({}) do |k,hsh|
      hsh.merge!(cond_search_param(k.split('_')[0], (k.split('_')[1]=='id'), scope_attrs.dig(k)))
    end
  end

  def cond_search_param(k, id, v)
    {k.to_sym => (id ? cond_find(k.classify.constantize, v) : v)}
  end

  def product_hattrs(product:nil, hattrs:{})
    hattr_params(product_keys, (product ? product.tags : hattrs))
  end

  def item_hattrs(hattrs:{})
    hattr_params(Item.hattr_keys, hattrs)
  end

  def hattr_params(keys, hattrs={})
    filter_h(keys, hattrs)
  end

  def product_keys
    %w[table_skus items item_products].include?(controller_name) ? Product.hattr_keys[0..1] : Product.hattr_keys
  end

  def filter_h(keys, hattrs={})
    keys.each_with_object({}) {|k,h| h[k] = hattrs.dig(k)}
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
