class FieldItem < ApplicationRecord
  include STI
  include Fieldable
  include Crudable

  has_many :item_groups, as: :origin
end
