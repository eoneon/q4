class Item < ApplicationRecord

  include Fieldable
  include Crudable
  include FieldCrud
  include ProductCrud
  include ItemProduct
  include BatchCreate
  include Hashable
  include TypeCheck
  include Description
  include Textable
  include ExportAttrs
  include SkuRange
  include Search

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :products, through: :item_groups, source: :target, source_type: "Product"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  belongs_to :invoice, optional: true

  before_create :set_qty

  def set_qty
    self.qty = 1 if qty.blank?
  end

  # COLLECTIONS ################################################################
  def product
    products.first if products.any?
  end

  def artist
    artists.first if artists.any?
  end

  def hattr(hstore,k)
    public_send(hstore).dig(k) unless !public_send(hstore)
  end

  def i_args
    {i_params: config_item_params, options: options, field_sets: joined_field_sets} if tags
  end
  ##############################################################################

  def sku_pos
    invoice.skus.index(self)
  end

  def first_sku
    invoice.first_sku
  end

  def last_sku
    invoice.last_sku
  end

  def next_sku
    invoice.skus[sku_pos+1]
  end

  def prev_sku
    invoice.skus[sku_pos-1]
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

  ##############################################################################
  #############################################################
  def init_input_group(fields, input_group={:param_hsh=>{}, :d_hsh=>{}, :context=>{}, :inputs=>[], :attrs=>{}})
    tags.each_with_object (input_group) {|(key, selected), hsh| Item.case_merge(input_group, (tag_attr?(key.split('::')[1]) ? selected : fields.detect{|f| f.id==(selected.to_i)}), :param_hsh, *key.split('::'))}
  end

  def config_inputs_and_d_hsh(fields:nil, input_group:nil)
  	(fields ? fields : product.unpacked_fields).each_with_object(input_group ? input_group : init_input_group(fieldables)) do |f, input_group|
      k, t, f_name = f.fattrs
      tb_tags_from_field(input_group[:d_hsh], f, k)
  		if field_set?(t)
  			config_inputs_and_d_hsh(fields: f.fieldables, input_group: input_group)
  		elsif !no_assocs?(t)
  			push_input_and_config_selected(k, t, f_name, f, input_group)
      elsif no_assocs?(t)
        input_group[:context][k.to_sym] = true if contexts[:present_keys].include?(k)
  		end
  	end
  end


  # def config_inputs_and_d_hsh(fields:nil, input_group:nil)
  # 	(fields ? fields : product.unpacked_fields).each_with_object(input_group ? input_group : init_input_group(fieldables)) do |f, input_group|
  #     tb_tags_from_field(input_group[:d_hsh], f, f.kind.underscore)
  # 		if field_set?(f.type)
  # 			config_inputs_and_d_hsh(fields: f.fieldables, input_group: input_group)
  # 		elsif !no_assocs?(f.type)
  # 			push_input_and_config_selected(*f.fattrs, f, input_group)
  #     elsif no_assocs?(f.type)
  #       input_group[:context][f.kind.underscore.to_sym] = true if contexts[:present_keys].include?(f.kind.underscore)
  # 		end
  # 	end
  # end

  def push_input_and_config_selected(k, t, f_name, f, input_group)
  	input_group[:inputs] << f_hsh(k, t, f_name, f)
  	if selected = input_group[:param_hsh].dig(k, t_type(t), f_name)
      context_from_selected(k, t, f_name, selected, input_group[:context])
  		input_group[:inputs][-1][:selected] = format_selected(t, selected)
  		tag_attr?(t) ? selected_tag_attr(input_group[:d_hsh], selected, k, f_name) : selected_field(input_group, selected, *selected.fattrs)
  	end
  end

  # def update_prev_kind(k, input_group)
  #   if !input_group[:prev_kind]
  #     input_group[:prev_kind] = k
  #   elsif input_group[:prev_kind] != k
  #     #puts "2-k=>#{k}, 2-prev_kind=>#{input_group[:prev_kind]}"
  #     update_prev_kind_case(input_group[:prev_kind], tb_keys, input_group[:context], input_group[:d_hsh])
  #   	input_group[:prev_kind] = k
  #     #puts "d_hsh=>#{input_group[:d_hsh]}"
  #   end
  # end

  # def update_prev_kind_case(k, tb_keys, context, d_hsh)
  #   puts "d_hsh[k]=>#{d_hsh[k]}"
  # 	case k
  # 	when 'numbering'; LimitedEdition.config_numbering_params(k, tb_keys, context, d_hsh)
  # 	end
  # end

  def selected_tag_attr(d_hsh, selected, k, f_name)
    if k=='dimension'
      Dimension.measurement_hsh(d_hsh, selected, k, f_name)
    else
      Item.case_merge(d_hsh, selected, k, f_name)
    end
  end

  def selected_field(input_group, selected, k, t, f_name)
  	tags_from_selected_field(input_group[:d_hsh], input_group[:context], selected, k, t, f_name) if selected.tags
  	config_inputs_and_d_hsh(fields: selected.fieldables, input_group: input_group) if field_set?(t)
  end

  def context_from_selected(k, t, f_name, selected, context)
  	context[k.to_sym] = true if contexts[:present_keys].include?(k)
    context[:valid] = true if %w[medium sculpture_type].include?(k)
  	LimitedEdition.numbering_context(f_name, context) if k == 'numbering'
  	return if tag_attr?(t) || selected.tags.blank?
  	if tag_val = selected.tags.dig('tagline')
  		set_tagline_vals_context(k, tag_val, context)
  	end
  end

  # def tags_from_selected_field(d_hsh, context, selected, k, t, f_name)
  # 	if Dimension.related_kinds.include?(k)
  # 		related_field_params(d_hsh, selected, k, t, f_name)
  # 	else
  # 		tb_tags_from_field(d_hsh, selected, k)
  # 	end
  # end

  def tags_from_selected_field(d_hsh, context, selected, k, t, f_name)
    related_field_params(d_hsh, selected, k, t, f_name) if Dimension.related_kinds.include?(k)
  	tb_tags_from_field(d_hsh, selected, k) unless k=='dimension'
  end

  def tb_tags_from_field(d_hsh, f, k)
    (%w[material_mounting mounting_search] + tb_keys).map {|tag_key| Item.case_merge(d_hsh, f.tags[tag_key], k, tag_key)} if f.tags
  end

  # def related_field_params(d_hsh, f, k, t, f_name, top_key='related_params')
  # 	f.tags.select{|k,v| (tb_keys + %w[material_mounting mounting_search] + Dimension.tags).include?(k) && v != 'n/a'}.each do |tag_key, tag_val|
  # 		keys = Dimension.tags.include?(tag_key) ? [top_key, 'dimension', tag_key, 'tag'] : [top_key, k, tag_key]
  # 		Item.case_merge(d_hsh, tag_val, *keys)
  # 	end
  # end

  def related_field_params(d_hsh, f, k, t, f_name)
  	f.tags.select{|k,v| Dimension.tags.include?(k) && v != 'n/a'}.each do |tag_key, tag_val|
  		Item.case_merge(d_hsh, tag_val, 'dimension', tag_key, 'tag')
  	end
  end

  def format_selected(t, selected)
  	tag_attr?(t) ? selected : selected.id
  end
  #############################################################
  # def config_params
  # 	tags.select{|k,v| tag_attr?((k.split('::')[1]))}.each_with_object ({:inputs=>[]}) do |(key, val), hsh|
  # 		Item.case_merge(hsh, val, :param_hsh, *key.split('::'))
  # 		Item.case_merge(hsh, val, :tag_hsh, key.split('::')[0], key.split('::')[-1])
  # 	end
  # end


  # def config_params
  # 	fields = fieldables
  # 	tags.each_with_object ({:param_hsh=>{}, :tag_hsh=>{}, :inputs=>[]}) do |(key, val), hsh|
  # 		k,t,f_name = key.split('::')
  # 		if tag_attr?(t)
  # 			Item.case_merge(hsh, val, :param_hsh, k, t, f_name)
  # 			Item.case_merge(hsh, val, :tag_hsh, k, f_name)
  # 		elsif f = fields.detect{|f| f.id==(val.to_i)}
  # 			tag_hsh_loop(f, hsh[:tag_hsh])
  # 			Item.case_merge(hsh[:param_hsh], f, k, t, f_name)
  # 		end
  # 	end
  # end

  def get_inputs_and_tag_hsh(fields:nil, input_group:nil)
  	(fields ? fields : product.unpacked_fields).each_with_object(input_group ? input_group : config_params) do |f, input_group|
  		tag_hsh_loop(f, input_group[:tag_hsh])
  		if field_set?(f.type)
  			get_inputs_and_tag_hsh(fields: f.fieldables, input_group: input_group)
  		elsif !no_assocs?(f.type)
  			push_input_and_selected(*f.fattrs, f, input_group)
  		end
  	end
  end
  # def config_params
	# 	hsh = tags.each_with_object ({}) {|(k,v), tag_hsh| Item.case_merge(tag_hsh, v, *k.split('::')) if tag_attr?(k.split('::')[1])}
	# 	{:tag_hsh=> hsh, :param_hsh=> hsh, :inputs=>[]}
  # end

  # def grouped_params
  # 	fieldables.each_with_object (config_params) do |f, config_params|
  # 		tag_key_loop(*f.fattrs, f, config_params[:tag_hsh])
  #     puts "tag_hsh1=======>#{config_params[:tag_hsh]}"
  # 		if kv_pair = tags.reject{|k,v| tag_attr?(k.split('::')[1])}.detect{|k,v| f.id==v.to_i}
  # 			Item.case_merge(config_params[:param_hsh], f, *kv_pair[0].split('::'))
  # 		end
  # 	end
  # end

  # def push_input_and_selected(k, t, f_name, f, input_group)
  # 	input_group[:inputs] << f_hsh(k, t, f_name, f)
  # 	if selected = input_group[:param_hsh].dig(k, t_type(t), f_name)
  #     #here?
  # 		input_group[:inputs][-1][:selected] =  tag_attr?(t) ? selected : selected.id
  #     get_inputs_and_tag_hsh(fields: selected.fieldables, input_group: input_group) if !tag_attr?(t) && field_set?(selected.type)
  # 	end
  # end
  ##############################################################################
  # def config_fparams
  # 	fieldables.each_with_object ({}) do |f, param_hsh|
  # 		if kv_pair = tags.reject{|k,v| tag_attr?(k.split('::')[1])}.detect{|k,v| f.id==v.to_i}
  # 			Item.case_merge(param_hsh, f, *kv_pair[0].split('::'))
  # 		end
  # 	end
  # end

  def param_group(input_group={:inputs=> []})
    input_group[:tag_hsh] = options.each_with_object({}) {|opt,tag_hsh| tag_key_loop(*opt.fattrs, opt, tag_hsh)}
    input_group[:i_params] = config_item_params
    #input_group[:tag_hsh].merge!(merge_tag_hsh(input_group[:i_params]))
    input_group
  end

  def merge_tag_hsh(i_params)
    i_params.each_with_object({}) do |(k,v), tag_hsh|
    	k,t,f_name = k.split('::')
    	Item.case_merge(tag_hsh, v, k, t, f_name) if tag_attr?(t)
    end
  end

  def inputs_and_tag_hsh(fields:nil, input_group:nil)
    (fields ? fields : field_sets).each_with_object(input_group ? input_group : param_group) do |f, input_group|
      k, t, f_name = pull_tags_and_return_fargs(f, input_group, *f.fattrs)
      if field_set?(f.type)
        inputs_and_tag_hsh(fields: f.fieldables, input_group: input_group)
      else
        config_input_and_selected(k, t, f_name, f, input_group)
      end
    end
  end

  ##############################################################################

  class << self

    def search(scopes:, product_hattrs:, item_hattrs:, context: nil)
    	inputs = Product.search(scopes: scopes, product_hattrs: product_hattrs, context: context)
      results_and_inputs(scopes[:product], scopes[:artist], scopes[:title], inputs[:product][:opts], valid_params(item_hattrs), item_hattrs, inputs)
    	inputs
    end

    def results_and_inputs(product, artist, title, products, item_params, item_hattrs, inputs, hstore='csv_tags')
      items = item_results(product, artist, title, valid_hattr_params(inputs[:hattrs]).merge(item_params), hstore)
      inputs[:items] = uniq_and_sorted_set(items, hstore, table_keys)
      inputs[:hattrs].merge!(initialize_search_inputs(item_hattrs, inputs[:items].pluck(hstore)))
    end

    def item_results(product, artist, title, search_params, hstore)
    	items = item_set(product, artist)
    	items = search_query(items, search_params, hstore)
    	items.any? && title ? items.where(title: title) : items
    end

    def item_set(product, artist)
    	case
    		when !product && !artist; []
    		when product && artist; artist.product_items(product)
    		when product; product.items
    		when artist; artist.items
    	end
    end

    def table_keys
    	%w[search_tagline mounting_search item_size width height]
    end

    def scope_keys
      %w[product_id artist_id title]
    end

    def hattr_keys
      %w[mounting_search measurements edition]
    end

    def search_keys
      %w[category_search medium_search material_search mounting_search measurements edition] #measurements item_size
    end

    def items_scoped_by_products(products)
      joins(:products).where(products: {id: products.ids})
    end

    def with_these(products)
    	joins(:products).where(products: {id: products}).uniq
    end

    def artist_items(artist_id)
      joins(:artists).where(artists: {id: artist_id}).distinct
    end
  end

end

############################################################################## #results_or_self = attr_group(results_or_self, default_params(attrs, attr_search_keys), input_group)
############################################################################
# def item_search_hattr_inputs(hattrs, items_tags)
#   hattrs.each_with_object([]) do |(k,v), hattr_inputs|
#     #{k=>search_input(k,v,items_tags)}
#     hattr_inputs.append({'input_name'=> k, 'selected'=> v, 'opts'=> search_opts(items_tags, k)})
#   end
# end

# def item_search(product:nil, artist:nil, title: nil, hattrs:nil, hstore:'csv_tags', inputs:{})
#   hattrs = hattr_params(product, hattrs, hstore)
#   results_or_self = search_case(artist, product)
#   results_or_self = title_search(results_or_self, title)
#   results = hstore_cascade_search(results_or_self, hattrs.reject{|k,v| v.blank?}, hstore, [])
#   results = order_hstore_search(results, %w[search_tagline item_size], hstore)
#   a, b = uniq_hattrs(results, search_keys, hstore), form_inputs(product, artist, title, hattrs, results, hstore, inputs)
# end
#
# def form_inputs(product, artist, title, hattrs, results, hstore, inputs)
#   origins_targets_inputs(product, 'Item', 'Product', results, inputs)
#   origins_targets_inputs(artist, 'Item', 'Artist', results, inputs)
#   inputs['title'] = {'selected' => title, 'opts'=> (results.any? ? results.pluck(:title).uniq : results)}
#   results, hstore = results.any? ? [results, hstore] : [Product, 'tags']
#   inputs['hattrs'] = search_inputs(results, hattrs, hstore)
#   inputs
# end
#
# def search_case(artist, product)
#   case
#     when artist && product; artist.product_items(product)
#     when artist; artist.items
#     when product; product.items
#     when !artist && !product; self
#   end
# end
#
# def title_search(results_or_self, title)
#   title.blank? ? results_or_self : results_or_self.where(title: title)
# end

# def self.hattr_search_fields(results, hattrs, hstore)
#   hattrs.each_with_object({}) do |(k,v), hattr_inputs|
#     hattr_inputs.merge!({k=> search_input(k, v, results, hstore)})
#   end
# end
#
# def self.hattr_opts(results, k, hstore)
#   results.map{|i| i.public_send(hstore)[k]}.uniq.compact
# end
#
# def self.attr_search_fields(attrs, results)
#   attrs.each_with_object({}) do |(k,v), attr_inputs|
#     attr_inputs.merge!({k => {'opts' => results.pluck(k.to_sym).uniq, 'selected' =>v}})
#   end
# end
