class Artist < ApplicationRecord
  has_many :item_groups, as: :origin

  def self.tag_field_sets
    [%w[first_name middle_name last_name], %w[title_tag description_tag], %w[yob yod]]
  end
end
