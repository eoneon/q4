class Material < ProductItem

  has_many :materials, through: :item_groups, source: :target, source_type: "Material"
  has_many :mountings, through: :item_groups, source: :target, source_type: "Mounting"
end
