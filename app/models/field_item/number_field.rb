class NumberField < FieldItem
  validates :type, :field_name, presence: true

  def self.builder(f)
    number_field = NumberField.where(field_name: f[:field_name]).first_or_create
    update_tags(number_field, f[:tags])
    number_field
  end
end
