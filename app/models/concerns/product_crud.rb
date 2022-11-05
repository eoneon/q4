require 'active_support/concern'

module ProductCrud
  extend ActiveSupport::Concern

  def add_product(product, dup=nil)
  	add_obj(product)
  	assign_fields_and_tags(get_default_product_fields(product.unpacked_fields))
  	assign_cvtags_with_rows(form_and_data, dup) if dup
  end

  def assign_fields_and_tags(fields_and_tags)
  	fields_and_tags[:fields].map{|f| assoc_unless_included(f)}
  	self.tags = fields_and_tags[:tags]
    self.save
  end

  def assign_cvtags_with_rows(form_n_data, dup=nil)
    puts "form_n_data=>#{form_n_data}"
    self.csv_tags = form_n_data[-1]
  	self.save
  	dup ? self : form_n_data[0]
  end

  def get_default_product_fields(fields)
  	fields.each_with_object({:fields=>[], :tags=>{}}) do |f, fields_and_tags|
  		k, t, f_name = *f.fattrs
  		next if no_assocs?(t)
  		get_default_fields_and_tags(k, t, f_name, f, fields_and_tags)
  	end
  end

  def get_default_fields_and_tags(k, t, f_name, f_val, fields_and_tags)
  	if f = default_field(k, t, f_val)
  		fields_and_tags[:fields] << f
  		add_tag_assoc(f.kind.underscore, t, f_name, f.id, fields_and_tags[:tags])
  	end
  end

  ##############################################################################

  def remove_product(product)
    remove_fieldables
    remove_obj(product)
  end

  def replace_product(item_product, product)
    remove_product(item_product)
    add_product(product)
  end
end

##############################################################################

# def update_product_case(t, old_val, new_val)
#   old_id, new_id = item_val(t, old_val), param_val(t, new_val)
#   case update_case(old_id, new_id)
#     when :add; add_product(new_val(t, new_id))
#     when :remove; remove_product(old_val)
#     when :replace; replace_product(old_val, new_val(t, new_id))
#     #when :skip; form_and_data(action: 'show')
#   end
# end



# def add_default_product_fields(fields)
# 	fields.each_with_object({}) do |f, tags|
# 		k, t, f_name = *f.fattrs
# 		next if no_assocs?(t)
# 		add_default(k, t, f_name, f, tags)
# 	end
# end
