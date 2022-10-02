class SelectField < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"

  def add_and_assoc_targets(target_group, assoc)
    target_group.map {|f_args| assoc_unless_included(Option.builder(f_args[0], f_args[1], f_args[2], assoc))}
  end

end
