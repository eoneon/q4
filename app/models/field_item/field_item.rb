class FieldItem < ApplicationRecord
  has_many :item_groups, as: :origin, dependent: :destroy
end
