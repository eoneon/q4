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

  def self.join_group(origin_type, origin_ids, target_type)
    where(origin_type: origin_type, origin_id: origin_ids, target_type: target_type).distinct
  end

end
