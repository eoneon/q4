class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ItemProduct
  include Hashable
  include TypeCheck
  include Description
  include Textable
  include ExportAttrs
  include SkuRange
  include Search

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :products, through: :item_groups, source: :target, source_type: "Product"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  ##############################################################################
  def batch_create_skus(invoice, product, product_args, artist, skus)
    skus.each do |sku|
      i = Item.create(sku: sku, qty: 1, invoice: invoice)
      i.add_obj(artist) if artist
      i.add_sku(product, product_args, sku) if product
    end
  end

  def add_sku(product, product_args, sku)
    add_obj(product)
    self.tags = hsh_init(self.tags)
    add_default_fields(product_args)
    rows, attrs = input_group
    update_csv_tags(attrs)
  end

  ##############################################################################
  def update_product_case(t, old_val, new_val)
    old_id, new_id = item_val(t, old_val), param_val(t, new_val)
    case update_case(old_id, new_id)
      when :add; add_product(new_val(t, new_id))
      when :remove; remove_product(old_val)
      when :replace; replace_product(new_val(t, new_id), old_val)
    end
  end

  def add_product(product)
    add_obj(product)
    self.tags = hsh_init(self.tags)
    add_default_fields(product.f_args(product.g_hsh))
  end

  def remove_product(product)
    remove_fieldables
    remove_obj(product)
  end

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end

  def self.artist_items(artist_id)
    joins(:artists).where(artists: {id: artist_id}).distinct
  end

  def hsh_init(tags)
    tags ? tags : {}
  end
  ############################################################################## #results_or_self = attr_group(results_or_self, default_params(attrs, attr_search_keys), input_group)
  def self.search(scope:nil, attrs:{}, hattrs:{}, input_group:{}, hstore: 'csv_tags')
    results_or_self = scope_group(scope, :item_groups, input_group)
    results = hstore_group(results_or_self, default_params(hattrs, search_keys), hstore, input_group, nil)
    args = results.any? ? [results, input_group['hattrs'], hstore] : [Product, input_group['hattrs'], 'tags']
    input_group['hattrs'] = search_inputs(*args)
    a, b = results, input_group
  end

  def self.hattr_search_fields(results, hattrs, hstore)
    hattrs.each_with_object({}) do |(k,v), hattr_inputs|
      hattr_inputs.merge!({k=> search_input(k, v, results, hstore)})
    end
  end

  def self.hattr_opts(results, k, hstore)
    results.map{|i| i.public_send(hstore)[k]}.uniq.compact
  end

  def self.attr_search_fields(attrs, results)
    attrs.each_with_object({}) do |(k,v), attr_inputs|
      attr_inputs.merge!({k => {'opts' => results.pluck(k.to_sym).uniq, 'selected' =>v}})
    end
  end

  def self.table_keys
    %w[search_tagline mounting_search measurements]
  end

  def self.search_keys
    %w[title category_search medium_search material_search mounting_search measurements] #item_size
  end

  ##############################################################################

  def tagline_title
    "\"#{self.title}\"" unless self.title.blank?
  end

  def body_title
    tagline_title ? tagline_title : 'This'
  end

  def attrs_title
    tagline_title ? tagline_title : 'Untitled'
  end

  def product
    products.first if products.any?
  end

  def artist
    artists.first if artists.any?
  end

  def hattr(hstore,k)
    public_send(hstore).dig(k) unless !public_send(hstore)
  end

end


# def self.search(scope:nil, joins:nil, hstore:nil, search_keys:nil, sort_keys:nil, attrs:{}, hattrs:{}, input_group:{})
#   set = scope_group(scope, joins, input_group)
#   set = attr_group(set, attrs, input_group)
#
#   hattr_group(set, hattrs, hstore, input_group)
#   #format_search(input_group, input_group['search_results'], search_keys, sort_keys, hstore)
#   format_search(input_group, input_group['search_results'], sort_keys[0..-2], sort_keys, hstore)
#   input_group
# end

# def self.format_search(input_group, search_results, search_keys, sort_keys, hstore)
#   return if !search_keys || !hstore
#   uniq_search(input_group, search_results, search_keys, hstore)
#   order_search(input_group['search_results'], sort_keys, hstore)
# end

# def self.uniq_search(input_group, search_results, search_keys, hstore)
#   input_group['search_results'] = uniq_hattrs(search_results, search_keys, hstore) if search_keys
# end
#
# def self.order_search(search_results, sort_keys, hstore)
#   search_results.sort_by!{|i| sort_keys.map{|k| sort_value(i.public_send(hstore)[k])}} if sort_keys
# end
#
# def self.sort_value(val)
#   is_numeric?(val) ? val.to_i : val
# end
#
# def self.is_numeric?(s)
#   !!Float(s) rescue false
# end

# join_search (I) ############################################################
# def self.scope_group(scope, joins, input_group)
#   input_group.merge!({'scope' => scope.try(:id), 'search_results' => scope_results(scope, joins)})
#   scope_set(input_group)
# end
#
# def self.scope_results(scope, joins)
#   joins && scope ? scope_query(scope, joins) : []
# end
#
# def self.scope_set(input_group)
#   input_group['search_results'].blank? ? self : input_group['search_results']
# end
#
# def self.scope_query(scope, joins)
#   self.joins(joins).where(joins => scope_query_params(scope))
# end
#
# def self.scope_query_params(scope)
#   {target_type: scope.class.base_class.name, target_id: scope.id}
# end

# attr_search (II) ###########################################################
# def self.attr_group(set, attrs, input_group)
#   return set if attrs.empty? #|| input_group['search_results'].empty?
#   attr_opts = attr_options(attrs, input_group['search_results'])
#   input_group.merge!({'attrs' => attr_opts, 'search_results' => attr_results(set, attrs.reject{|k,v| v.blank?}, input_group)})
#   attr_set(input_group)
# end
#
# def self.attr_results(set, attrs, input_group)
#   attrs.blank? ? input_group['search_results'] : input_group['search_results'].where(attrs)
# end
#
# def self.attr_set(input_group)
#   input_group['search_results'].blank? ? self : input_group['search_results']
# end

# hattr_search (III) #######################################################
# def self.hattr_group(set, hattrs, hstore, input_group)
#   return if !hstore
#   hattr_query_case(set, hattrs.reject{|k,v| v.blank?}, hstore, input_group)
#   input_group.merge!({'hattrs' => search_options(input_group['opt_set'], hattrs, hstore)})
# end
#
# def self.hattr_query_case(set, hattrs, hstore, input_group)
#   opt_set = hattr_search_query(set, hattrs, hstore)
#   input_group.merge!({'opt_set'=> opt_set, 'search_results'=> hattr_results(hattrs, opt_set, input_group['search_results'])})
# end
#
# def self.hattr_search_query(set, hattrs, hstore)
#   if hattrs.empty?
#     #index_query(set, hattrs.keys, hstore)
#     index_query(set, sort_keys[0..-2], hstore)
#   else
#     search_query(set, hattrs, hstore)
#   end
# end

# def self.hattr_results(hattrs, opt_set, search_results)
#   hattrs.empty? ? search_results : opt_set
# end
#
# def self.index_query(set, keys, hstore)
#   puts "index_query: #{hstore}?& ARRAY[:keys], keys: #{keys}"
#   set.where("#{hstore}?& ARRAY[:keys]", keys: keys)
# end
#
# def self.search_query(set, hattrs, hstore)
#   puts "search_query: #{hattrs.to_a.map{|kv| query_params(kv[0], kv[1], hstore)}.join(" AND ")}"
#   set.where(hattrs.to_a.map{|kv| query_params(kv[0], kv[1], hstore)}.join(" AND "))
# end
#
# def self.query_params(k,v, hstore)
#   "#{hstore} -> \'#{k}\' = \'#{v}\'"
# end
#
# def self.query_order(keys, hstore)
#   keys.map{|k| "#{hstore} -> \'#{k}\'"}.join(', ')
# end
#

# def self.uniq_hattrs(set, keys, hstore, list=[], uniq_set=[])
#   set.each do |i|
#     assign_unique(i, keys, hstore, list, uniq_set)
#   end
#   uniq_set
# end
#
# def self.assign_unique(i, keys, hstore, list, uniq_set)
#   puts "keys: #{keys}"
#   h = keys.map{|k| [k, i.public_send(hstore)[k]]}.to_h
#   return if list.include?(h)
#   list << h
#   uniq_set << i
# end

#new methods: #############################################################################
# def self.index_hstore_input_group(search_keys, sort_keys, hstore, input_group:{}, search_results:nil)
#   opt_set = uniq_hattrs(index_query(self, search_keys, hstore), search_keys, hstore)
#   puts "opt_set: #{opt_set}"
#   opt_set = order_search(opt_set, sort_keys, hstore)
#   build_hstore_input_group(search_keys, opt_set, hstore, input_group, search_results)
# end
#
# def self.build_hstore_input_group(search_keys, opt_set, hstore, input_group, search_results)
#   search_results = search_results.nil? ? opt_set : search_results
#   input_group.merge!({'hattrs' => search_options(opt_set, default_hsh(search_keys), hstore), 'search_results' => search_results, 'scope' => nil, 'attrs' => attr_options(default_hsh(attr_search_keys), [])})
# end
