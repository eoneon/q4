class ChangeOptionsToTags < ActiveRecord::Migration[5.1]
  def change
    rename_column :field_items, :options, :tags
  end
end
