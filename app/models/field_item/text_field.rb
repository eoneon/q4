class TextField < FieldItem
  validates :type, :field_name, presence: true

  # def self.builder(f)
  #   text_field = TextField.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
  #   update_tags(text_field, f[:tags])
  #   text_field
  # end

  # revisit: id_tags
  def self.builder(f)
    text_field = TextField.where(field_name: f[:field_name], kind: f[:kind], tags: id_tags(f[:tags])).first_or_create
    update_tags(text_field, f[:tags])
    text_field
  end
end
