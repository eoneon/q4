class Product < ApplicationRecord

  include Fieldable
  include Crudable
  include Hashable
  include TypeCheck
  #include HattrSearch
  include Search

  validates :product_name, presence: true
  validates :product_name, uniqueness: true

  has_many :item_groups, as: :origin
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  # GROUPING METHODS: CRUD/VIEW ################################################
  def product_item_loop(i_hsh, f_grp, keys)
    product_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], tags)
    product_item_fields_loop(g_hsh, i_hsh, f_grp[:rows], f_grp[:d_hsh], keys)
    f_grp[:rows] = assign_row(f_grp[:rows].group_by{|h| h[:k]}, form_rows(f_grp[:context], f_grp[:attrs]['medium']))
  end

  def product_attrs(context, d_hsh, attrs, p_tags)
    context[product_category(p_tags['product_type'])] = true
    Medium.item_tags.map(&:to_s).map{|k| attrs[k] = p_tags[k]}
  end

  # inputs_and_selected_make_attrs_and_rows ####################################
  def product_item_fields_loop(g_hsh, i_hsh, rows, d_hsh, keys)
    inputs = product_fields_loop(g_hsh, d_hsh, keys)
    item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
  end

  def product_fields_loop(g_hsh, d_hsh, keys, inputs=[])
    Product.dig_keys_with_end_val(h: g_hsh).each_with_object(inputs) do |args, inputs|
      k, t, t_type, f_name, f = input_vals(*args[0..-2].map!(&:underscore).append(args[-1]))
      tags_loop(k, f_name, f, d_hsh, keys) if f.tags
      if field_set?(t)
        product_fields_loop(f.g_hsh, d_hsh, keys, inputs)
      elsif !radio_button?(t)
        inputs.append(input_hsh(k, t, f_name, f))
      end
    end
  end

  def item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
    inputs.each do |f_hsh|
      k, t, t_type, f_name, f = [:k,:t,:t_type,:f_name,:f_val].map{|key| f_hsh[key]}
      selected = i_hsh.dig(k, t_type, f_name)
      rows.append(f_hsh.merge!({:selected=> format_selected(selected,:id)}))
      tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys) if selected
    end
  end

  def tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys)
    if selected.is_a?(String)
      Item.case_merge(d_hsh, selected, k, f_name)
    else
      tags_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
      product_item_fields_loop(selected.g_hsh, i_hsh, rows, d_hsh, keys) if field_set?(selected.type)
    end
  end

  def tags_loop(k, f_name, f, d_hsh, keys)
    keys.each_with_object(d_hsh) do |tag, d_hsh|
      Item.case_merge(d_hsh, f.tags[tag], k, tag, f_name) if f.tags&.has_key?(tag)
    end
  end

  def assign_row(form_hsh, form_rows)
    form_rows.each_with_object([]).each do |form_row, rows|
      row = form_row.select{|col| form_hsh.has_key?(col)}
      rows.append(row.map!{|col| form_hsh[col]}.flatten!) if row.any?
    end
  end

  def format_selected(selected, attr)
    return selected if selected.nil? || selected.is_a?(String)
    selected.public_send(attr)
  end

  def format_fname(k, selected, f_name)
    k == 'dimension' && field_set?(selected.type) ? selected.field_name : f_name
  end

  def form_rows(context, medium)
    case
      when context[:flat_art] && medium != 'Sericel'; [%w[category medium embellishing leafing], %w[numbering], %w[material mounting], %w[dated signature certificate], %w[seal verification], %w[dimension], %w[disclaimer]]
      when context[:flat_art]; [%w[category medium], %w[numbering], %w[mounting], %w[dated signature verification], %w[seal certificate], %w[dimension], %w[disclaimer]]
      when context[:flat_art]; [%w[category numbering], %w[medium material embellishing], %w[mounting], %w[dated signature verification], %w[seal certificate], %w[dimension], %w[disclaimer]]
      when context[:sculpture_art]; [%w[category numbering], %w[sculpture_type embellishing], %w[dated signature certificate], %w[verification], %w[dimension], %w[disclaimer]]
      when context[:gartner_blade]; [%w[sculpture_type sculpture_part signature], %w[dimension], %w[disclaimer]]
    end
  end

  class << self

    # SEARCH METHODS ###########################################################
    def search(scope:nil, hattrs:nil, hstore:'tags')
      hattrs = hattr_params(scope, hattrs, hstore)
      results = hattr_search(self, hattrs.reject{|k,v| v.blank?}, hstore)
      a, b = results, search_inputs(results, hattrs, hstore)
    end

    def search_keys
      %w[category_search medium_search material_search]
    end

    # SEEDING METHODS ##########################################################
    def seed(store)
      Medium.class_group('ProductGroup').each_with_object(store) do |c, store|
        c.product_group(store)
      end
    end

    def builder(product_name, fields, tags=nil)
      p = Product.where(product_name: product_name).first_or_create
      p.update_tags(tags)
      p.assoc_targets(fields)
    end
  end

  def assoc_targets(targets)
    targets.each_with_object(self){|target,p| assoc_unless_included(target)}
  end

end

# THE END ######################################################################
################################################################################

# def search(scope:nil, hattrs:nil, hstore:'tags')
#   hattrs = hattr_params(scope, hattrs, hstore)
#   results = hstore_search(scope, hattrs, hstore)
#   a, b = results, search_inputs(results, hattrs, hstore)
# end

# def self.search(scope: nil, search_params: nil, restrict: nil, hstore:)
#   search_params = search_params(scope: scope, search_params: search_params, hstore: hstore)
#   results = hattr_search(scope: self, search_params: search_params, restrict: restrict, hstore: hstore)
#   a, b = results, search_inputs(search_params, results, hstore)
# end

# def self.hattr_params(scope,hstore)
#   search_keys.each_with_object({}) do |k,h|
#     if v = scope.public_send(hstore).dig(k)
#       h[k] = v if !v.blank?
#     end
#   end
# end

# def product_item_loop(i_hsh, f_grp, keys)
#   inputs = product_fields_loop(g_hsh, f_grp[:d_hsh], keys)
#   item_fields_loop(inputs, i_hsh, f_grp[:rows], f_grp[:d_hsh], keys)
#   f_grp[:rows] = assign_row(f_grp[:rows].group_by{|h| h[:k]}, form_rows(f_grp[:context], f_grp[:attrs]['medium']))
# end

# def tags_and_rows(k, f_name, selected, i_hsh, rows, d_hsh, keys)
#   if selected.is_a?(String)
#     Item.case_merge(d_hsh, selected, k, f_name)
#   else
#     tags_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
#     if field_set?(selected.type)
#       inputs = product_fields_loop(selected.g_hsh, d_hsh, keys)
#       item_fields_loop(inputs, i_hsh, rows, d_hsh, keys)
#     end
#   end
# end

# def kinds
#   Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
# end

# def d_hsh_and_row_params(g_hsh, i_hsh, f_grp, keys)
#   inputs = product_fields_loop(g_hsh, f_grp[:d_hsh], keys)
#   item_fields_loop(inputs, i_hsh, f_grp, keys)
#   #d_hsh_and_row_loop(g_hsh, i_hsh, f_grp)
#   f_grp.merge!({rows: assign_row(f_grp[:rows].group_by{|h| h[:k]})})
# end

# def d_hsh_and_row_loop(g_hsh, i_hsh, f_grp)
#   f_args(g_hsh).each_with_object(f_grp) do |f_hsh, f_grp|
#     k, t, t_type, f_name, f = [:k,:t,:t_type,:f_name,:f_val].map{|key| f_hsh[key]}
#     #
#     if radio_button?(t)
#       d_hsh_loop(:d_hsh, k, f_name, f, f_grp, 'tagline', 'body')
#     else
#       selected = i_hsh.dig(k, t_type, f_name)
#       f_grp[:rows].append(f_hsh.merge!({:selected=> format_selected(selected,:id)}))
#       tags_and_rows(k, f_name, selected, i_hsh, f_grp) if selected
#     end
#   end
# end

# def d_hsh_loop(k, f_name, f, d_hsh, tag_keys)
#   tag_keys.each_with_object(d_hsh) do |tag, d_hsh|
#     Item.case_merge(d_hsh, f.tags[tag], k, tag, f_name) if f.tags&.has_key?(tag) #puts "selected b: #{f}, f.f_name: #{f.field_name}, f_name: #{f_name}"
#   end
# end
# def tags_and_rows(k, f_name, selected, i_hsh, d_hsh, keys)
#   if selected.is_a?(String)
#     Item.case_merge(d_hsh, selected, k, f_name)
#   else
#     d_hsh_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
#     #d_hsh_loop(:d_hsh, k, format_fname(k, selected, f_name), selected, f_grp, ['tagline', 'body'])
#     d_hsh_and_row_loop(selected.g_hsh, i_hsh, d_hsh, keys) if field_set?(selected.type)
#   end
# end

# DRAFT/REPLACED METHODS #######################################################

#a = lambda {puts "dog"}#{Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)}
# def my_lambda
#   lambda {puts "dog"}
#   #a.call
# end

################################################################################

# def self.search_params(scope: nil, search_params: nil, hstore:)
#   search_keys.map{|k| [k, search_value(scope, search_params, hstore, k)]}.to_h
# end

# def self.search_value(scope, search_params, hstore, k)
#   if search_params
#     search_params[k]
#   elsif scope
#     scope.public_send(hstore)[k]
#   end
# end

# def self.search_inputs(search_params, results, hstore)
#   a = search_params.each_with_object([]) do |(k,v),a|
#     a.append(search_input(k, v, results, hstore))
#   end
# end
#
# def self.search_input(k, v, results, hstore)
#   {'input_name'=> k, 'selected'=> v, 'opts'=> results.map{|product| product.public_send(hstore)[k]}.uniq.compact}
# end

################################################################################
# def radio_options
#   radio_buttons.includes(:options).map(&:options)
# end

# def assign_or_merge(h, h2)
#   h.nil? ? h2 : h.merge(h2)
# end

#  product_type product_subtype
# def self.tag_search_field_group(search_keys:, products: product_group, h: {})
#   search_keys.map{|search_key| h[:"#{search_key}"] = search_values(products, search_key)}
#   h
# end

# def self.valid_search_keys(products=product_group)
#   filter_keys.keep_if {|k| uniq_tag_keys_from_set(products).include?(k)}
# end

# def self.uniq_tag_keys_from_set(products=product_group)
#   products.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end

# def self.search_values(products, search_key)
#   products.map{|product| product.tags[search_key]}.uniq.compact
# end

#all search keys-> remove?
# def self.search_keys(search_set)
#   search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end

# # targets.includes(item_groups: :target).map(&:target)
# # FieldItem.where(id: targets.map(&:id)).joins(:item_groups).order('item_groups.sort').includes(:target).map(&:target)
