class TextAreaField < FieldItem
  validates :type, :field_name, presence: true

  def self.builder(f)
    text_area_field = TextAreaField.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
    update_tags(text_field, f[:tags])
    text_area_field
  end
end
