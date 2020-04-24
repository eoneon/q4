class AddSortToItemGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :item_groups, :sort, :integer
  end
end
