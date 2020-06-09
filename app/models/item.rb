class Item < ApplicationRecord
  has_many :item_groups, as: :origin, dependent: :destroy
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
end
