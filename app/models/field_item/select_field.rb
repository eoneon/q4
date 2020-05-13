class SelectField < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  validates :field_name, uniqueness: true

  def self.builder(f)
    select_field = SelectField.where(field_name: f[:field_name]).first_or_create
    f[:options].map {|opt| select_field.assoc_unless_included(opt)}
    select_field
  end
end
