class FieldSet < FieldItem
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"
end
