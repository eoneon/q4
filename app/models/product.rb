class Product < ApplicationRecord

  include Fieldable
  include Crudable
  #include FieldCrud
  include TypeCheck

  include STI

  #validates :type, :product_name, presence: true
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

  scope :product_group, -> {self.all}

  ## p.prg_hsh(p) #############################################################################
  #item.input_params p.input_group_with_params(i.input_params)
  def input_group_with_params(input_params)
    input_group(g_hsh, input_params)
  end

  def input_group(field_groups, input_params, inputs={})
    param_args(field_groups: field_groups, unpack: true).each do |h|
      k, t, t_type, f_name, f_obj = h.values
      selected = input_params.dig(k,t_type,f_name)
      #selected = get_selected(k,t_type,f_name, input_params)
      param_merge(params: inputs, dig_set: dig_set(k: f_name, v: f_hsh(k, t, t_type, f_name, f_obj, selected), dig_keys: [k, t_type]))
      input_group(selected.g_hsh, input_params, inputs) if selected && t_type != 'tags' && selected.type == 'FieldSet'
    end
    inputs
  end

  # def get_selected(k,t_type,f_name, input_params)
  #   if t_type == "tags"
  #     input_params.dig(t_type, f_name)
  #   else
  #     input_params.dig(k,t_type,f_name)
  #   end
  # end

  def f_hsh(k, t, t_type, f_name, f_obj, selected)
    {render_as: t, kind_scope: k, type_scope: t_type, method: f_name, f_obj: f_obj, selected: format_selected(selected)}
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

  def field_items
    select_menus + field_sets + select_fields + text_area_fields
  end
  # def recursive_targets(targets=fieldables, target_set=[])
  #   return target_set if targets.empty?
  #   recursive_extract(targets, target_set.concat(targets))
  # end
  # # targets.includes(item_groups: :target).map(&:target)
  # # FieldItem.where(id: targets.map(&:id)).joins(:item_groups).order('item_groups.sort').includes(:target).map(&:target)

  # def recursive_extract(targets, target_set)
  #   return target_set if targets.empty?
  #   recursive_extract(fieldables, target_set.concat(targets))
  # end
  #
  # def fieldables
  #   item_groups.where(base_type: 'FieldItem').order(:sort).includes(:target).map(&:target)
  # end

  # def self.recursive_targets(targets, target_set=[])
  #   return target_set if targets.empty?
  #   recursive_extract(targets, target_set.concat(targets))
  # end
  #
  # def self.recursive_extract(targets, target_set)
  #   return target_set if targets.empty?
  #   recursive_extract(join_ftargets(targets), target_set.concat(targets))
  # end
  #
  # def self.join_ftargets(targets)
  #   ItemGroup.where(origin_type: "FieldItem", origin_id: targets.map(&:id) ).includes(:target).map(&:target)
  # end

  ##############################################################################

  def field_targets
    #scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many, reject_set: ['RadioButton'])
    scoped_targets(scope: 'FieldItem', join: :item_groups, sort: :sort, reject_set: ['RadioButton'])
  end

  ##############################################################################

  def self.tag_search_field_group(search_keys:, products: product_group, h: {})
    search_keys.map{|search_key| h[:"#{search_key}"] = search_values(products, search_key)}
    h
  end

  def self.valid_search_keys(products=product_group)
    filter_keys.keep_if {|k| uniq_tag_keys_from_set(products).include?(k)}
  end

  def self.uniq_tag_keys_from_set(products=product_group)
    products.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
  end

  def self.search_values(products, search_key)
    products.map{|product| product.tags[search_key]}.uniq.compact
  end

  ##############################################################################

  def self.filter_keys
    %w[medium_category medium material]
  end

  #all search keys-> remove?
  def self.search_keys(search_set)
    search_set.pluck(:tags).map{|tags| tags.keys}.flatten.uniq
  end

  # def self.ordered_types
  #   set=[]
  #   product_types = Product.file_set[1..-1]
  #   (1..product_types.count).each do |i|
  #     type = product_types.detect{|type| type.classify.constantize.type_order == i}
  #     set << type.classify
  #   end
  #   set
  # end

end
