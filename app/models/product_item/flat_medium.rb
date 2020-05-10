class FlatMedium < ProductItem
  has_many :flat_materials, through: :item_groups, source: :target, source_type: "FlatMaterial"
  has_many :sub_media, through: :item_groups, source: :target, source_type: "SubMedium"
  has_many :certificates, through: :item_groups, source: :target, source_type: "Certificate"
end
