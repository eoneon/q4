class FieldItem < ApplicationRecord
  include STI

  has_many :item_groups, as: :origin
  #validates :type, :field_name, presence: true
end
