class Option < FieldItem
  validates :field_name, uniqueness: true

  def self.builder(opt_set)
    opt_set.map{|opt_name| Option.where(field_name: opt_name).first_or_create}
  end
end
