class RadioButton < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"

end
