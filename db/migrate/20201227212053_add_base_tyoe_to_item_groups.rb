class AddBaseTyoeToItemGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :item_groups, :base_type, :string
  end
end
