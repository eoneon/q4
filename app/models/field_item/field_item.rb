class FieldItem < ApplicationRecord

  include Fieldable
  include Crudable
  include TypeCheck

  has_many :item_groups, as: :origin
  validates :type, :field_name, presence: true

  def fattrs
  	[:kind, :type, :field_name].map{|attr| public_send(attr).underscore}
  end

  # def add_and_assoc_targets(target_group)
  #   assoc_targets(add_targets(target_group))
  # end

  def add_and_assoc_targets(target_group, assoc)
  	add_targets(target_group, assoc).map{|target| assoc_unless_included(target)}
  end

  def add_targets(target_group, assoc)
    puts "target_group=>#{target_group}"
  	target_group.map{|target_args| add_target(target_args, assoc)}
  end

  def add_target(target_args, assoc)
  	update_assocs(to_class(target_args[0]).where(field_name: target_args[2], kind: target_args[1]).first_or_create, assoc)
  end

  def update_assocs(target, assoc)
  	return target if target.assocs && target.assocs.has_key?(assoc)
    puts "target=>#{target}, target.assocs=>#{target.assocs}"
  	target.assocs = assign_or_merge(target.assocs, {assoc=>true})
  	target.save
    target
  end

  def self.seed
    Medium.class_group('FieldGroup').reverse.each_with_object({}) do |c, store|
      c.build_and_store(:targets, store)
    end
  end
end


# def self.hm_assocs
#   self.reflect_on_all_associations(:has_many).map{|assoc| assoc.name.to_s} #plural
# end
