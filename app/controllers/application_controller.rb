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

  #search ######################
  def artist_search_params(artist:)
  	search_params = {scopes: config_scope_hsh(filter_h(Item.scope_keys)), product_hattrs: filter_h(product_keys), item_hattrs: filter_h(Item.hattr_keys)}
  	search_params[:scopes]['artist'] = artist
  	search_params
  end

  def item_search_params(store: param_hsh, scope_keys: Item.scope_keys, product: nil)
    search_params, new_item_hsh = product_search_params(store: store, scope_keys: scope_keys, product: product), filter_h(Item.hattr_keys)
    search_params[:item_hattrs] = (product || search_params[:scopes][:artist] ? Product.update_default_hsh_from_old_hsh(new_item_hsh.keys, new_item_hsh, store) : new_item_hsh)
    search_params
  end

  def product_search_params(store: param_hsh, scope_keys: Product.scope_keys, product:nil)
  	new_scope_hsh, new_product_hsh = filter_h(scope_keys), filter_h(product_keys)
    scope_hsh, product_hattrs = config_product_search_params(product, new_scope_hsh, new_product_hsh, store)
  	{scopes: scope_hsh, product_hattrs: product_hattrs, context: param_hsh.dig('items', 'context')}
  end

  def config_product_search_params(product, new_scope_hsh, new_product_hsh, store)
  	if action_name=='create'
      new_product_search_args(new_scope_hsh, new_product_hsh)
    elsif %w[table_skus items].include?(controller_name)
      update_product_search_args(product, new_scope_hsh, new_product_hsh, store)
    else
      [scopes_from_params(new_scope_hsh.keys, new_scope_hsh, store), Product.update_default_hsh_from_old_hsh(new_product_hsh.keys, new_product_hsh, store)]
    end
  end

  def new_product_search_args(new_scope_hsh, new_product_hsh)
    [config_scope_hsh(new_scope_hsh), new_product_hsh]
  end

  def config_scope_hsh(scope_hsh)
    scope_hsh.transform_keys!{|k,v| k.split('_')[0].to_sym}
  end

  def update_product_search_args(product, new_scope_hsh, new_product_hsh, store)
  	scope_hsh = product ? scopes_from_product(product, new_scope_hsh) : scopes_from_params(new_scope_hsh.keys, new_scope_hsh, store)
  	store_hsh = scope_hsh[:product] ? scope_hsh[:product].tags : store
  	[scope_hsh, Product.update_default_hsh_from_old_hsh(new_product_hsh.keys, new_product_hsh, store_hsh)]
  end

  def scopes_from_product(product, new_scope_hsh)
    scopes = scope_hsh(new_scope_hsh)
    scopes[:product] = product
    scopes
  end

  def scopes_from_params(scope_keys, new_scope_hsh, store_hsh)
    scopes = Product.update_default_hsh_from_old_hsh(new_scope_hsh.keys, new_scope_hsh, store_hsh)
    scopes = scope_hsh(scopes)
    scopes
  end

  def scope_hsh(scope_hsh)
    scope_hsh.each_with_object({}) do |(k,v),hsh|
      hsh.merge!(cond_search_param(k.split('_')[0], (k.split('_')[1]=='id'), v))
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
  #######################dig_keys_for_param_update
  def dig_keys_for_param_update(str)
  	Item.strip_space([['[',' '], [']', '']].map{|swap| str.gsub!(swap[0], swap[1])}.last).split(' ')
  end
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
    sku_range.all?{|i| i.length <= 5} || sku_range.all?{|i| i.length == 6}
  end

  def asc_range?(sku_range)
    sku_range[0].to_i < sku_range[1].to_i
  end

  def format_sku(sku, skus)
    skus << sku.to_i if sku.length <= 5 || sku.length == 6
  end

  def extract_digits(num_str)
    num_str.gsub(/\D/, '')
  end
end
