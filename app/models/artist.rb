class Artist < ApplicationRecord
  has_many :item_groups, as: :origin
  has_many :field_sets, through: :item_groups, source: :target, source_type: "FieldSet"

  def self.options
    FieldSet.find_by(field_name: 'artist-field').item_groups.order(:sort).map{|item_group| item_group.target}
  end
end
