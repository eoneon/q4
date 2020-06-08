class CreateArtists < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :artists do |t|
      t.string :artist_name
      t.hstore :tags

      t.timestamps
    end
  end
end
