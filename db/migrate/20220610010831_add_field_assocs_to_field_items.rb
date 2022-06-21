class AddFieldAssocsToFieldItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :field_items, :field_assocs, :hstore
  end
end
