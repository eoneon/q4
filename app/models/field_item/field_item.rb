class FieldItem < ApplicationRecord

  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
  validates :type, :field_name, presence: true
  # h = FieldItem.seed
  # h = FieldItem.seed_fields
  # h = FieldItem.seed_fields[:set]

  # def self.seed
  #   Medium.class_group('FieldGroup').each_with_object({}) do |c, store|
  #     c.build_and_store(:targets, store)
  #     c.assoc_fields(store)
  #   end
  # end

  def self.seed
    Medium.assoc_fields(seed_fields)
  end

  def self.seed_fields
    Medium.class_group('FieldGroup').each_with_object({}) do |c, store|
      c.build_and_store(:targets, store)
    end
  end

end
