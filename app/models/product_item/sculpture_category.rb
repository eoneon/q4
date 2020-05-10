class SculptureCategory < ProductItem
  has_many :sculpture_media, through: :item_groups, source: :target, source_type: "SculptureMedium"
end
