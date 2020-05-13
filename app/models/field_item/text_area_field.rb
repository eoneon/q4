class TextAreaField < FieldItem
  validates :type, :field_name, presence: true
  
  def self.builder(f)
    TextAreaField.where(field_name: f[:field_name]).first_or_create
  end
end
