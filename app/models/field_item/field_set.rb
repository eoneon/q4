class FieldSet < FieldItem
  has_many :select_menus, through: :item_groups, source: :target, source_type: "SelectMenu"
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"
  has_many :select_fields, through: :item_groups, source: :target, source_type: "SelectField"
  has_many :check_box_fields, through: :item_groups, source: :target, source_type: "CheckBoxField"
  has_many :radio_buttons, through: :item_groups, source: :target, source_type: "RadioButton"
  has_many :text_fields, through: :item_groups, source: :target, source_type: "TextField"
  has_many :number_fields, through: :item_groups, source: :target, source_type: "NumberField"
  has_many :text_area_fields, through: :item_groups, source: :target, source_type: "TextAreaField"

  def self.media_kind
    FieldSet.where("tags -> 'kind' = 'medium'")
  end

  def self.media_sub_kind
    media_kind.pluck(:tags).map{|h| h["sub_kind"]}.uniq
  end  

  def self.builder(f)
    #field_set = FieldSet.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
    field_set = FieldSet.where(field_name: f[:field_name]).first_or_create
    update_tags(field_set, f[:tags])
    f[:options].map {|opt| field_set.assoc_unless_included(opt)}
    field_set
  end
end
