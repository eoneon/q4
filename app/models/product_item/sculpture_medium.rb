class SculptureMedium < ProductItem
  has_many :sculpture_materials, through: :item_groups, source: :target, source_type: "SculptureMaterial"
  has_many :sub_media, through: :item_groups, source: :target, source_type: "SubMedium"
end
