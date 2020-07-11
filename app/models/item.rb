class Item < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :standard_products, through: :item_groups, source: :target, source_type: "StandardProduct"
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  has_many :artists, through: :item_groups, source: :target, source_type: "Artist"
  belongs_to :invoice, optional: true

  attribute :standard_product
  attribute :product
  attribute :options
  attribute :select_menus

  def product
    if product = targets.detect{|target| target.class.method_defined?(:type) && target.base_type == 'Product'}
      product
    end
  end

  def product_id
    product.id if product
  end

  def artist
    artists.first if artists.any?
  end

  def artist_id
    artist.id if artist
  end

  #target_fields: move to sti concern so :item and :product can use this method
  def field_targets
    scoped_sti_targets_by_type(scope: 'FieldItem', rel: :has_many)
  end

  def field_target_params(h={})
    field_targets.each do |field|
      h[field_param_key(f)] = field.id
    end
    h
  end

  def field_param_key(f)
    [field.kind, field.type.underscore].join('_')
  end

  #can be used for Product or FieldItem
  # def scoped_sti_targets_by_type(scope, assoc_type=:has_one)
  #   target_set = scoped_type_targets(scope) #=> [] or set
  #   child_set(target_set, assoc_type) if target_set.any?
  # end
  #
  # def scoped_type_targets(scope)
  #   targets.keep_if {|target| target.class.method_defined?(:type) && target.base_type == scope}
  # end
  #
  # def child_set(target_set, assoc_type)
  #   if assoc_type == :has_one
  #     target_set[0]
  #   else
  #     target_set
  #   end
  # end
end
