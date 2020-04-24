class Category < ProductItem
  has_many :media, through: :item_groups, source: :target, source_type: "Medium"
  has_many :editions, through: :item_groups, source: :target, source_type: "Edition"
end
