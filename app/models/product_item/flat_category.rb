class FlatCategory < ProductItem
  has_many :flat_media, through: :item_groups, source: :target, source_type: "FlatMedium"
end
