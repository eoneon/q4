class SelectMenu < FieldItem
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"

  # def add_and_assoc_targets(target_group)
  #   assoc_targets(add_targets(target_group))
  # end

  def add_and_assoc_targets(target_group)
    target_group.map{|args| assoc_unless_included(to_class(args[0]).where(field_name: args[2], kind: args[1]).first_or_create)}
  end

  # def add_targets(target_group)
  #   target_group.map{|target_set| to_class(target_set[0]).where(field_name: target_set[2], kind: target_set[1]).first_or_create}
  # end

  # def add_targets(target_group)
  #   target_group.map{|target_set| assoc_unless_included(to_class(target_set[0]).where(field_name: target_set[2], kind: target_set[1]).first_or_create)}
  # end

  # def assoc_targets(targets)
  #   targets.map{|target| self.assoc_unless_included(target)}
  # end
end
