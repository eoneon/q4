class AddFassocsToProducts < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :products, :assocs, :hstore
  end
end
