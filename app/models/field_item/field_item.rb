class FieldItem < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin
end
