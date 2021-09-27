class Product < ApplicationRecord

  include Fieldable
  include Crudable
  include Hashable
  include TypeCheck
  include HattrSearch

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
  # def d_hsh_and_row_params(g_hsh, i_hsh, f_grp, keys)
  #   inputs = product_fields_loop(g_hsh, f_grp[:d_hsh], keys)
  #   item_fields_loop(inputs, i_hsh, f_grp, keys)
  #   #d_hsh_and_row_loop(g_hsh, i_hsh, f_grp)
  #   f_grp.merge!({rows: assign_row(f_grp[:rows].group_by{|h| h[:k]})})
  # end

  def d_hsh_and_row_params(g_hsh, i_hsh, f_grp, keys)
    inputs = product_fields_loop(g_hsh, f_grp[:d_hsh], keys)
    item_fields_loop(inputs, i_hsh, f_grp, keys)
    f_grp.merge!({rows: assign_row(f_grp[:rows].group_by{|h| h[:k]})})
  end

  def item_fields_loop(inputs, i_hsh, f_grp, keys)
    inputs.each_with_object(f_grp) do |f_hsh, f_grp|
      k, t, t_type, f_name, f = [:k,:t,:t_type,:f_name,:f_val].map{|key| f_hsh[key]}
      selected = i_hsh.dig(k, t_type, f_name)
      f_grp[:rows].append(f_hsh.merge!({:selected=> format_selected(selected,:id)}))
      tags_and_rows(k, f_name, selected, i_hsh, f_grp[:d_hsh], keys) if selected
    end
  end

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
  def tags_and_rows(k, f_name, selected, i_hsh, d_hsh, keys)
    if selected.is_a?(String)
      Item.case_merge(d_hsh, selected, k, f_name)
    else
      tags_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
      if field_set?(selected.type)
        inputs = product_fields_loop(selected.g_hsh, d_hsh, keys)
        item_fields_loop(inputs, i_hsh, d_hsh, keys)
      end
    end
  end

  def tags_loop(k, f_name, f, d_hsh, keys)
    keys.each_with_object(d_hsh) do |tag, d_hsh|
      Item.case_merge(d_hsh, f.tags[tag], k, tag, f_name) if f.tags&.has_key?(tag) #puts "selected b: #{f}, f.f_name: #{f.field_name}, f_name: #{f_name}"
    end
  end



  # def tags_and_rows(k, f_name, selected, i_hsh, d_hsh, keys)
  #   if selected.is_a?(String)
  #     Item.case_merge(d_hsh, selected, k, f_name)
  #   else
  #     d_hsh_loop(k, format_fname(k, selected, f_name), selected, d_hsh, keys)
  #     #d_hsh_loop(:d_hsh, k, format_fname(k, selected, f_name), selected, f_grp, ['tagline', 'body'])
  #     d_hsh_and_row_loop(selected.g_hsh, i_hsh, d_hsh, keys) if field_set?(selected.type)
  #   end
  # end

  def assign_row(f_grp)
    kinds.each_with_object([]) do |form_row, rows|
      row = form_row.select{|col| f_grp.has_key?(col)}
      rows.append(row.map!{|col| f_grp[col]}.flatten!) if row.any?
    end
  end

  def format_selected(selected, attr)
    return selected if selected.nil? || selected.is_a?(String)
    selected.public_send(attr)
  end

  def format_fname(k, selected, f_name)
    k == 'dimension' && field_set?(selected.type) ? selected.field_name : f_name
  end

  def kinds
    Medium.class_group('FieldGroup').map{|c| c.call_if(:input_group)}.compact.sort_by(&:first).map(&:last)
  end

  ##############################################################################
  ##############################################################################

  # SEARCH METHODS #############################################################
  def self.search(scope: nil, search_params: nil, restrict: nil, hstore:)
    search_params = search_params(scope: scope, search_params: search_params, hstore: hstore)
    results = hattr_search(scope: self, search_params: search_params, restrict: restrict, hstore: hstore)
    a, b = results, search_inputs(search_params, results, hstore)
  end

  def self.search_keys
    %w[category_search medium_search material_search]
  end
  ##############################################################################
  ##############################################################################

  # SEEDING METHODS ############################################################
  def self.seed(store)
    Medium.class_group('ProductGroup').each_with_object(store) do |c, store|
      c.product_group(store)
    end
  end

  def self.builder(product_name, fields, tags=nil)
    p = Product.where(product_name: product_name).first_or_create
    p.update_tags(tags)
    p.assoc_targets(fields)
  end

  def assoc_targets(targets)
    targets.each_with_object(self){|target,p| assoc_unless_included(target)}
  end

end

# THE END ######################################################################
################################################################################
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
