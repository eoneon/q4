class Material < ProductItem
  #attribute :material_id, :integer

  has_many :materials, through: :item_groups, source: :target, source_type: "Material"
  has_many :mountings, through: :item_groups, source: :target, source_type: "Mounting"
  # accepts_nested_attributes_for :materials, allow_destroy: true
  # accepts_nested_attributes_for :mountings, allow_destroy: true
end
