class FieldItem < ApplicationRecord
  include STI
  include Fieldable

  has_many :item_groups, as: :origin
end
