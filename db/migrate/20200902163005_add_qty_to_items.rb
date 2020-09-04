class AddQtyToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :items, :qty, :integer
  end
end
