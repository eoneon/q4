class FlatMaterial < ProductItem
  has_many :flat_materials, through: :item_groups, source: :target, source_type: "FlatMaterial"
  has_many :flat_mountings, through: :item_groups, source: :target, source_type: "FlatMounting"
end
