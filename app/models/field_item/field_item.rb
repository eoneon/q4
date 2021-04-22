class FieldItem < ApplicationRecord
  
  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
end
