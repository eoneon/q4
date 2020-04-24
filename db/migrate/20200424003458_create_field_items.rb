class CreateFieldItems < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :field_items do |t|
      t.string :type
      t.string :field_name
      t.hstore :options

      t.timestamps
    end
  end
end
