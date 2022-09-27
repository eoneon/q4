class SelectField < FieldItem
  has_many :options, through: :item_groups, source: :target, source_type: "Option"
  #validates :field_name, uniqueness: true

  def add_and_assoc_targets(target_group, assoc)
    target_group.map {|f_args| assoc_unless_included(Option.builder(f_args[0], f_args[1], f_args[2], assoc))}
  end

  # def add_and_assoc_targets(targets)
  #   targets.map {|f_args| assoc_unless_included(Option.builder(*f_args))}
  # end
end



# def add_and_assoc_targets(targets)
#   targets.each do |f_args|
#     opt = Option.builder(*f_args)
#     assoc_unless_included(opt)
#   end
# end

# def add_and_assoc_targets(target_names)
#   assoc_targets(add_targets(target_names))
# end

# def add_targets(target_names)
#   target_names.map{|target_name| Option.where(field_name: target_name, kind: self.kind).first_or_create}
# end
#
# def assoc_targets(targets)
#   targets.map{|target| assoc_unless_included(target)}
# end
