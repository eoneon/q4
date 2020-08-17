class ItemGroup < ApplicationRecord
  before_create :set_sort
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
    origin.item_groups.where.not(target_type: 'Artist')
  end

  def max_sort
    origin_item_groups.count
  end

  def ordered_item_groups(origin)
    origin.item_groups.order(:sort).map{|item_group| item_group}
  end

  def targets(origin)
    ordered_item_groups(origin).map{|item_group| item_group.target}
  end

end
