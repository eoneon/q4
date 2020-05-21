class RadioButton < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  validates :type, :field_name, presence: true

  def self.builder(f)
    radio_button = RadioButton.where(field_name: f[:field_name], tags: id_tags(f[:tags])).first_or_create
    update_tags(radio_button, f[:tags])
    radio_button
  end
end
