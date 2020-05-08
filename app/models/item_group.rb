class ItemGroup < ApplicationRecord
  before_create :set_sort
  before_destroy :update_sort

  belongs_to :origin, polymorphic: true
  belongs_to :target, polymorphic: true

  def update_sort
    unless self.sort == max_sort
      origin_targets.where("sort > ?", self.sort).each do |target|
        target_sort = target.sort
        target.update(sort: target_sort -1)
      end
    end
  end

  def set_sort
    self.sort = max_sort + 1
  end

  def origin_targets
    origin.item_groups
  end

  def max_sort
    origin_targets.count
  end

end
