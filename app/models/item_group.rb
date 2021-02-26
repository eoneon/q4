class ItemGroup < ApplicationRecord
  #include STI

  before_create :set_sort, :set_base_type
  before_destroy :update_sort

  belongs_to :origin, polymorphic: true
  belongs_to :target, polymorphic: true

  def update_sort
    unless self.sort == max_sort
      origin_item_groups.where("sort > ?", self.sort).each do |target|
        target_sort = target.sort
        target.update(sort: target_sort -1)
      end
    end
  end

  def set_sort
    self.sort = max_sort + 1
  end

  def origin_item_groups
    origin.item_groups.where(base_type: 'FieldItem')
  end

  def set_base_type
    self.base_type = target.class.base_class.name
  end

  def max_sort
    origin_item_groups.count
  end

end

# def scoped_targets
#   target.item_groups.includes(:target)
# end

# def origin_item_groups
#   #need to check if there's a folder in dir; otherwise use target_type
#   target_type = sti_obj?(target) ? scoped_assocs(target.base_type) : target.base_type
#   origin.item_groups.where(target_type: target_type)
# end

# def ordered_item_groups(origin)
#   origin.item_groups.order(:sort).map{|item_group| item_group}
# end
#
# def targets(origin)
#   ordered_item_groups(origin).map{|item_group| item_group.target}
# end
