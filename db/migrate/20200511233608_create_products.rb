class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :products do |t|
      t.string :type
      t.string :product_name
      t.hstore :tags

      t.timestamps
    end
  end
end
