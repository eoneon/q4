class TextField < FieldItem
  validates :type, :field_name, presence: true

  def self.builder(f)
    text_field = TextField.where(field_name: f[:field_name]).first_or_create
    update_tags(text_field, f[:tags])
    text_field
  end
end
