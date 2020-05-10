class SculptureMaterial < ProductItem
  has_many :depth_mountings, through: :item_groups, source: :target, source_type: "DepthMounting"
end
