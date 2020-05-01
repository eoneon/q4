class ProductItem < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin, dependent: :destroy

  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"
  # accepts_nested_attributes_for :materials, allow_destroy: true
  # accepts_nested_attributes_for :mountings, allow_destroy: true
end
