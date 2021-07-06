class SelectField < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"

  def add_and_assoc_targets(target_names)
    assoc_targets(add_targets(target_names))
  end

  def add_targets(target_names)
    target_names.map{|target_name| Option.where(field_name: target_name, kind: self.kind).first_or_create}
  end

  def assoc_targets(targets)
    targets.map{|target| assoc_unless_included(target)}
  end
end
