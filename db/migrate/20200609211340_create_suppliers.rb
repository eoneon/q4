class CreateSuppliers < ActiveRecord::Migration[5.1]
  def change
    create_table :suppliers do |t|
      t.string :supplier_name
      
      t.timestamps
    end
  end
end
