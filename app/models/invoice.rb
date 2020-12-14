class Invoice < ApplicationRecord
  belongs_to :supplier, optional: true
  has_many :items, dependent: :destroy

  def supplier_name
    supplier.supplier_name if supplier
  end

  def display
    "#{invoice_name}: #{invoice_number}" #if invoice.present?
  end
end
