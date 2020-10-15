class AddCsvTagsToItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :items, :csv_tags, :hstore
  end
end
