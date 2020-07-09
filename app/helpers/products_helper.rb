module ProductsHelper

  def product_fields(product, set=[])
    filtered_fields(product).each do |f|
      set << build_f_hsh(f)
    end
    set
  end

  def filtered_fields(product)
    product.targets.keep_if{|target| render_types.include?(target.type)}
  end

  def build_f_hsh(f)
    public_send(f.type.underscore + '_group', f)
  end

  ##############################################################################

  def select_field_group(f)
    h={render_as: f.type.underscore, label: f.tags["kind"], method: fk_id(f.tags["kind"]), collection: f.options}
  end

  def field_set_group(f)
    h={render_as: f.type.underscore, label: f.tags["kind"], method: fk_id(f.tags["kind"]), collection: f.targets}
  end

  def build_field_set_group(fields)
    fields.map{|f| build_f_hsh(f)}
  end

  def select_menu_group(f)
    h={render_as: f.type.underscore, label: f.tags["kind"], method: fk_id(f.tags["kind"]), collection: f.targets}
  end

  #tags

  def number_field_group(f)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.tags["kind"])}
  end

  def text_field_group(f)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.tags["kind"])}
  end

  ##############################################################################

  def default_product(product)
    product ? product.type : Product.ordered_types.first
  end

  def product_type(product)
    product.type if product
  end

  def product_id(product)
    product.id if product
  end

  def product_tags(product)
    product.tags if product
  end

  def render_types
    ['SelectField', 'FieldSet', 'SelectMenu']
  end
end
