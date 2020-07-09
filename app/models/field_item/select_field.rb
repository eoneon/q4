class SelectField < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"

  def self.builder(f)
    select_field = SelectField.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
    update_tags(select_field, f[:tags])
    f[:options].map {|opt| select_field.assoc_unless_included(opt)}
    select_field
  end

  # revisit id_tags
  
  # def self.builder(f)
  #   select_field = SelectField.where(field_name: f[:field_name], kind: f[:kind], tags: id_tags(f[:tags])).first_or_create
  #   update_tags(select_field, f[:tags])
  #   f[:options].map {|opt| select_field.assoc_unless_included(opt)}
  #   select_field
  # end
end
