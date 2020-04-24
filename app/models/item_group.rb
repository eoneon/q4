class ItemGroup < ApplicationRecord
  belongs_to :origin, polymorphic: true
  belongs_to :target, polymorphic: true

  # before_create :set_sort
  #
  # def set_sort
  #   self.sort = set_count + 1
  # end
  #
  # def set_count
  #   if ["ProductPart", "ItemField", "ItemValue, Element"].include?(self.origin_type)
  #     origin.sti_item_groups(target_type).count
  #   else
  #     origin.item_groups.count
  #   end
  # end
end
