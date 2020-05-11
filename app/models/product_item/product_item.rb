class ProductItem < ApplicationRecord
  include STI

  validates :type, :item_name, presence: true
  validates :item_name, uniqueness: true

  has_many :item_groups, as: :origin #, dependent: :delete_all
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"


  type_search.each do |h|
    scope h[:scope], -> { where(type: h[:type]) }
  end
end
