class CreateItemGroups < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :item_groups do |t|
      t.references :origin, polymorphic: true, index: true
      t.references :target, polymorphic: true, index: true
      t.hstore :tags
      
      t.timestamps
    end
  end
end
