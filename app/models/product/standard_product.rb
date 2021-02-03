class StandardProduct < Product
  def self.builder(f)
    product = self.where(product_name: f[:product_name]).first_or_create
    update_tags(product, f[:tags])
    f[:options].map {|opt| product.assoc_unless_included(opt)}
    product
  end

  def self.type_order
    1
  end
end
