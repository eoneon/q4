class ItemGroup < ApplicationRecord
  before_create :set_sort

  belongs_to :origin, polymorphic: true
  belongs_to :target, polymorphic: true

  def set_sort
    self.sort = origin.item_groups.count + 1
  end

end
