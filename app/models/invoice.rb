class Invoice < ApplicationRecord
  belongs_to :supplier, optional: true
  has_many :items, dependent: :destroy

  def supplier_name
    supplier.supplier_name if supplier
  end

  def display
    "#{invoice_number}: #{invoice_name}" 
  end

  ##############################################################################

  def skus
    items.order(:sku)
  end

  def first_sku
    skus.first
  end

  def last_sku
    skus.last
  end

  def sku_count
    skus.count
  end
end
