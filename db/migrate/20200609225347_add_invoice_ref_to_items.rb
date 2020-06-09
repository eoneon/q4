class AddInvoiceRefToItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :items, :invoice, foreign_key: true, index: true
  end
end
