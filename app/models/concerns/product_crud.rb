require 'active_support/concern'

module ProductCrud
  extend ActiveSupport::Concern

  def update_product_case(t, old_val, new_val)
    old_id, new_id = item_val(t, old_val), param_val(t, new_val)
    case update_case(old_id, new_id)
      when :add; add_product(new_val(t, new_id))
      when :remove; remove_product(old_val)
      when :replace; replace_product(new_val(t, new_id), old_val)
    end
  end

  def add_product(product)
  	add_obj(product)
  	tags = add_default_product_fields(product.unpacked_fields)
  	self.tags = tags
  	self.save
  end

  def add_default_product_fields(fields)
  	fields.each_with_object({}) do |f, tags|
  		k, t, f_name = *f.fattrs
  		next if no_assocs?(t)
  		add_default(k, t, f_name, f, tags)
  	end
  end

  def remove_product(product)
    remove_fieldables
    remove_obj(product)
  end

  def replace_product(product, item_product)
    remove_product(item_product)
    add_product(product)
  end
end


# def add_default(k, t, f_name, f, tags)
# 	if selected = default_field(k, t, f)
# 		add_field(k, selected.type.underscore, f_name, selected, tags)
# 	end
# end

# def add_product(product)
#   add_obj(product)
#   self.tags = hsh_init(self.tags)
#   add_default_fields(product.f_args(product.g_hsh))
#   #new_product_group(product.unpacked_fields)
# end
