class FieldItem < ApplicationRecord

  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
  validates :type, :field_name, presence: true

  def fattrs
  	[:kind, :type, :field_name].map{|attr| public_send(attr).underscore}
  end
  
  def self.seed
    Medium.class_group('FieldGroup').reverse.each_with_object({}) do |c, store|
      c.build_and_store(:targets, store)
    end
  end
end
