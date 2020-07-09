class NumberField < FieldItem
  validates :type, :field_name, presence: true

  # def self.builder(f)
  #   number_field = NumberField.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
  #   update_tags(number_field, f[:tags])
  #   number_field
  # end

  def self.builder(f)
    number_field = NumberField.where(field_name: f[:field_name], kind: f[:kind], tags: id_tags(f[:tags])).first_or_create
    update_tags(number_field, f[:tags])
    number_field
  end
end
