class SelectMenu < FieldItem
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"

end
