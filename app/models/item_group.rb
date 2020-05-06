class ItemGroup < ApplicationRecord
  before_create :set_sort

  belongs_to :origin, polymorphic: true
  belongs_to :target, polymorphic: true

  def set_sort
    self.sort = origin.item_groups.count + 1
  end

  #use in order to get parent in other methods
  # def origin
  #   origin_type.classify.constantize.find(origin_id)
  # end

  # def targets
  #   origin.item_groups.order(:sort)
  # end
  #
  # def target_count
  #   targets.count
  # end
end
