class CreateProductItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :product_items do |t|
      t.string :type
      t.string :item_name
      t.hstore :tags
      
      t.timestamps
    end
  end
end
