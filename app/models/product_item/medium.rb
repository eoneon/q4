class Medium < ProductItem
  has_many :materials, through: :item_groups, source: :target, source_type: "Material"
  has_many :sub_media, through: :item_groups, source: :target, source_type: "SubMedium"
  has_many :certificate, through: :item_groups, source: :target, source_type: "Certificate"
end
