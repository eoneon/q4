class SelectField < FieldItem
  has_many :select_values, through: :item_groups, source: :target, source_type: "SelectValue"
end
