class AddFassocsToFieldItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :field_items, :assocs, :hstore
  end
end
