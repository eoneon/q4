class SculptureCategory < ProductItem
  has_many :sculpture_media, through: :item_groups, source: :target, source_type: "SculptureMedium"
  #has_many :editions, through: :item_groups, source: :target, source_type: "Edition"
end
