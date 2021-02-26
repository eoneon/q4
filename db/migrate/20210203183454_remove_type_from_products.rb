class RemoveTypeFromProducts < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :type, :string
  end
end
