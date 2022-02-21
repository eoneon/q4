class Product < ApplicationRecord

  include Fieldable
  include Crudable
  include Hashable
  include TypeCheck
  include Search

  validates :product_name, presence: true
  validates :product_name, uniqueness: true

  has_many :item_groups, as: :origin
  has_many :item_groups, as: :target

  has_many :items, through: :item_groups, source: :origin, source_type: "Item"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  # def items
  #   Item.joins(:products).where(products: {id: id})
  # end

  # GROUPING METHODS: CRUD/VIEW ################################################
  def product_item_loop(i_hsh, f_grp, keys)
    product_attrs(f_grp[:context], f_grp[:d_hsh], f_grp[:attrs], tags)
    product_item_fields_loop(g_hsh, i_hsh, f_grp[:rows], f_grp[:d_hsh], keys)
    f_grp[:rows] = build_form_rows(f_grp[:rows].group_by{|h| h[:k]}, media_group(f_grp[:context]).merge!(form_groups))
  end

  def product_attrs(context, d_hsh, attrs, p_tags)
    context[product_category(p_tags['product_type'])] = true
    Medium.tag_keys.map{|k| attrs[k] = p_tags[k]}
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

  def format_selected(selected, attr)
    return selected if selected.nil? || selected.is_a?(String)
    selected.public_send(attr)
  end

  def format_fname(k, selected, f_name)
    k == 'dimension' && field_set?(selected.type) ? selected.field_name : f_name
  end

  def media_group(context)
    case
      when context[:flat_art]; {'media'=> {header: %w[category embellishing medium], body: %w[leafing remarque]}}
      when context[:sculpture_art]; {'media'=> {header: %w[category embellishing medium sculpture_type], body: %w[]}}
      when context[:gartner_blade]; {'media'=> {header: %w[sculpture_type sculpture_part], body: %w[]}}
    end
  end

  def form_groups
    {
      'numbering'=> {header: %w[numbering], body: %w[]},
      'material_mounting'=> {header: %w[material mounting], body: %w[]},
      'authentication'=> {header: %w[seal signature certificate], body: %w[dated verification]},
      'dimension'=> {header: %w[dimension], body: %w[]},
      'disclaimer'=> {header: %w[disclaimer], body: %w[]}
    }
  end

  def build_form_rows(form_hsh, form_group)
    form_group.each_with_object({}) do |(card_id,card), hsh|
      if card[:header].any?{|k| form_hsh[k]}
        Item.case_merge(hsh, build_row(card[:header], form_hsh), card_id, :header)
        Item.case_merge(hsh, build_row(card[:body], form_hsh), card_id, :body)
      end
    end
  end

  def build_row(keys,hsh)
    row = keys.select{|k| hsh.has_key?(k)}.each_with_object([]){|k,div_row| div_row << hsh[k]}.flatten
    row = row.each_with_index {|f_hsh,i| f_hsh[:i] = i}
    row
  end

  class << self

    def invoice_search(product:nil, artist_id:nil, hattrs:nil, hstore:'tags', inputs:{})
      form_inputs(hattrs, product, artist_id, hstore, inputs)
      results = search_results(product, artist_id, inputs['hattrs'].reject{|k,v| v.blank?}, hstore)
      results = order_hstore_search(results, %w[category_search medium_search material_search], hstore)
      inputs['hattrs'] = search_inputs(results, inputs['hattrs'], hstore)
      a, b = results, inputs
    end

    def form_inputs(hattrs, product, artist_id, hstore, inputs)
      inputs['artist'] = product ? nil : artist_id
      inputs['hattrs'] = hattr_params(product, hattrs, hstore)
      inputs['product'] = !product ? nil : product.id
    end

    def search_results(product, artist_id, hattrs, hstore)
      results_or_self = scope_search_or_self(product, artist_id)
      hstore_search(results_or_self, hattrs, hstore)
    end

    def scope_search_or_self(product, artist_id)
      return self unless !product && artist_id && search_by_artists(artist_id).any?
      search_by_artists(artist_id)
    end

    def search_by_artists(artist_id)
      where(id: ItemGroup.join_group('Item', Item.artist_items(artist_id).ids, 'Product').pluck(:target_id))
    end

    # SEARCH METHODS ###########################################################
    def search(scope:nil, hattrs:nil, hstore:'tags')
      hattrs = hattr_params(scope, hattrs, hstore)
      results = hstore_search(self, hattrs.reject{|k,v| v.blank?}, hstore)
      results = order_hstore_search(results, search_keys, hstore)
      a, b = results, search_inputs(results, hattrs, hstore)
    end

    def search_keys
      %w[category_search medium_search] #material_search
    end
    # SEEDING METHODS ##########################################################
    def seed(store)
      Medium.class_group('ProductGroup').each_with_object(store) do |c, store|
        c.product_group(store)
      end
    end

    def builder(product_name, fields, tags=nil)
      p = where(product_name: product_name).first_or_create
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

# def titles
#   items.pluck(:title).uniq.reject{|i| i.blank?}
# end

# def row_context
#   {
#   'numbering'=> {'numbered_one_of_one'=> :one_of_one, 'numbering_type'=> :numbered},
#   'category'=> {'edition_type'=> :limited_edition},
#   'material'=> {'wrapped_canvas'=> :wrapped_canvas},
#   'medium'=> {'standard_sericel'=> :sericel, 'production_cel'=> :production_cel, 'acrylic_mixed_media'=> :acrylic_mixed_media},
#   'category_search'=> {'reproduction_print'=> :reproduction_print},
#   'material_search'=> {'paper'=> :paper}
#   }
# end

# def form_rows(context, p_set)
#   case
#     when context[:sericel] && context[:limited_edition] && p_set.include?('basic'); [%w[category medium mounting], %w[numbering], %w[dated signature verification], %w[seal certificate], %w[dimension], %w[disclaimer]]
#     when context[:sericel] && context[:limited_edition]; [%w[category medium mounting], %w[numbering], %w[signature seal certificate], %w[dimension], %w[disclaimer]]
#     when context[:sericel] && !context[:limited_edition]; [%w[medium mounting], %w[signature seal certificate], %w[dimension], %w[disclaimer]]
#
#     when context[:limited_edition]; [%w[category medium material], %w[embellishing leafing remarque], %w[mounting], %w[dated signature certificate], %w[dimension], %w[disclaimer]]
#
#     when context[:reproduction_print] && context[:paper]; [%w[medium material mounting], %w[embellishing leafing remarque], %w[dated signature certificate], %w[dimension], %w[disclaimer]]
#     when context[:reproduction_print]; [%w[medium material embellishing leafing], %w[remarque], %w[mounting], %w[dated signature certificate], %w[dimension], %w[disclaimer]]
#
#     when context[:acrylic_mixed_media] && p_set.include?('peter'); [%w[medium material mounting], %w[signature verification certificate], %w[dimension], %w[disclaimer]]
#     when context[:acrylic_mixed_media]; [%w[medium material mounting], %w[dated signature certificate], %w[dimension], %w[disclaimer]]
#
#     when context[:one_of_one] && context[:paper]; [%w[numbering medium embellishing leafing], %w[material mounting remarque], %w[dated signature certificate verification], %w[dimension], %w[disclaimer]]
#     when context[:one_of_one]; [%w[numbering medium embellishing leafing], %w[material mounting], %w[dated signature certificate verification], %w[dimension], %w[disclaimer]]
#     when context[:flat_art]; [%w[medium material mounting], %w[dated signature certificate], %w[seal verification], %w[dimension], %w[disclaimer]]
#     #when context[:flat_art]; [%w[category medium], %w[numbering], %w[mounting], %w[dated signature verification], %w[seal certificate], %w[dimension], %w[disclaimer]]
#     #when context[:flat_art]; [%w[category numbering], %w[medium material embellishing], %w[mounting], %w[dated signature verification], %w[seal certificate], %w[dimension], %w[disclaimer]]
#     when context[:sculpture_art]; [%w[category numbering], %w[sculpture_type embellishing], %w[dated signature certificate], %w[verification], %w[dimension], %w[disclaimer]]
#     when context[:gartner_blade]; [%w[sculpture_type sculpture_part signature], %w[dimension], %w[disclaimer]]
#   end
# end

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
# def radio_options
#   radio_buttons.includes(:options).map(&:options)
# end

# def self.uniq_tag_keys_from_set(products=product_group)
#   products.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end

#all search keys-> remove?
# def self.search_keys(search_set)
#   search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end

# # targets.includes(item_groups: :target).map(&:target)
# # FieldItem.where(id: targets.map(&:id)).joins(:item_groups).order('item_groups.sort').includes(:target).map(&:target)
