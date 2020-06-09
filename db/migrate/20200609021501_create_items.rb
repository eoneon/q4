class CreateItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :items do |t|
      t.integer :sku
      t.integer :retail
      t.hstore :tags

      t.timestamps
    end
  end
end
