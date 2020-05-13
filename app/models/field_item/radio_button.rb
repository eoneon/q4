class RadioButton < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  validates :type, :field_name, presence: true
  
  def self.builder(f)
    RadioButton.where(field_name: f[:field_name]).first_or_create
  end
end
