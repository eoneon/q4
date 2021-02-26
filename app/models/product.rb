class Product < ApplicationRecord
  include STI
  include Fieldable

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

  ##############################################################################

  def self.builder(f)
    product = self.where(product_name: f[:product_name]).first_or_create
    update_tags(product, f[:tags])
    f[:options].map {|opt| product.assoc_unless_included(opt)}
    product
  end

  # def nested_fieldables(h={})
  #   grouped_fieldables.each do |kind, set|
  #     h.merge!( {kind => set.map{|f| format_nested(f)} })
  #   end
  #   h
  # end
  #
  # def format_nested(f)
  #   #f.type == 'FieldSet' ? f.fieldables : f
  #   f.is_a? FieldSet ? f.fieldables : f
  # end

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
