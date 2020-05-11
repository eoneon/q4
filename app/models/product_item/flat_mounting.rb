class FlatMounting < ProductItem
  has_many :flat_mountings, through: :item_groups, source: :target, source_type: "FlatMounting"
end
