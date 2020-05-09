class FieldItem < ApplicationRecord
  include STI

  validates :type, :field_name, presence: true
  validates :field_name, uniqueness: true

  has_many :item_groups, as: :origin
end
