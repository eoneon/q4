class AddKindToItems < ActiveRecord::Migration[5.1]
  def change
    add_column :field_items, :kind, :string
  end
end
