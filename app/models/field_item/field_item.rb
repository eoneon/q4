class FieldItem < ApplicationRecord

  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
  validates :type, :field_name, presence: true

  def self.seed
    store = Medium.class_group('FieldGroup').each_with_object({}) do |c, store|
      c.class_cascade(store)
    end
  end
end
