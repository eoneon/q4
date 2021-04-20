class Product < ApplicationRecord

  include Fieldable
  include Crudable
  include Hashable
  include TypeCheck
  include HattrSearch

  include STI

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

  def radio_options
    radio_buttons.includes(:options).map(&:options)
  end

  def input_set(g_hsh, i_hsh, a=[])
    a = field_args(g_hsh).each_with_object(a) do |f_hsh, a|
      f = i_hsh.dig(f_hsh[:k], f_hsh[:t_type], f_hsh[:f_name])
      a.append(f_hsh.merge!({:selected=> format_selected(f)}))
      input_set(f.g_hsh, i_hsh, a) if f && !f.is_a?(String) && field_set?(f.type)
    end
  end

  def format_selected(selected)
    return selected if selected.nil? || selected.is_a?(String)
    selected.id
  end

  ##############################################################################

  def self.builder(f)
    product = self.where(product_name: f[:product_name]).first_or_create
    update_tags(product, f[:tags])
    f[:options].map {|opt| product.assoc_unless_included(opt)}
    product
  end

  # refactor: self.search_query ################################################
  def self.search(scope: nil, search_params: nil, hstore:)
    search_params = search_params(scope: scope, search_params: search_params, hstore: hstore)
    results = hattr_search(scope: self, search_params: search_params, hstore: hstore)
    a, b = results, search_inputs(search_params, results, hstore)
  end

  def self.search_params(scope: nil, search_params: nil, hstore:)
    search_keys.map{|k| [k, search_value(scope, search_params, hstore, k)]}.to_h
  end

  def self.search_value(scope, search_params, hstore, k)
    if search_params
      search_params[k]
    elsif scope
      scope.public_send(hstore)[k]
    end
  end

  def self.search_inputs(search_params, results, hstore)
    a = search_params.each_with_object([]) do |(k,v),a|
      a.append(search_input(k, v, results, hstore))
    end
  end

  def self.search_input(k, v, results, hstore)
    {'input_name'=> k, 'selected'=> v, 'opts'=> results.map{|product| product.public_send(hstore)[k]}.uniq.compact}
  end

  def self.search_keys
    %w[category medium product_type product_subtype]
  end

end

##############################################################################

# def self.tag_search_field_group(search_keys:, products: product_group, h: {})
#   search_keys.map{|search_key| h[:"#{search_key}"] = search_values(products, search_key)}
#   h
# end
#
# def self.valid_search_keys(products=product_group)
#   filter_keys.keep_if {|k| uniq_tag_keys_from_set(products).include?(k)}
# end
#
# def self.uniq_tag_keys_from_set(products=product_group)
#   products.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end
#
# def self.search_values(products, search_key)
#   products.map{|product| product.tags[search_key]}.uniq.compact
# end
#
# def self.filter_keys
#   %w[medium_category medium material]
# end

#all search keys-> remove?
# def self.search_keys(search_set)
#   search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
# end

# def field_targets
#   #scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many, reject_set: ['RadioButton'])
#   scoped_targets(scope: 'FieldItem', join: :item_groups, sort: :sort, reject_set: ['RadioButton'])
# end

# def field_items
#   select_menus + field_sets + select_fields + text_area_fields
# end

# # targets.includes(item_groups: :target).map(&:target)
# # FieldItem.where(id: targets.map(&:id)).joins(:item_groups).order('item_groups.sort').includes(:target).map(&:target)
