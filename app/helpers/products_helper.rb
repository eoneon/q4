module ProductsHelper

  def product_field_params(product, fields, item, vals, set=[])
    fields.each do |f|
      cascade_build_f_hsh(f, vals, set)
    end
    set
  end

  def cascade_build_f_hsh(f, vals, set)
    set << build_field(f, vals)
    #add_nested_field_set(set.last, vals, set) #if f.type == 'FieldSet'
  end

  def add_nested_field_set(f_hsh, vals, set)
    if f_hsh.has_key?(:selected) && f_hsh[:selected].present?
      cascade_build_f_hsh(f_hsh[:selected], vals, set)
    end
  end

  def build_field(f, vals)
    public_send(f.type.underscore + '_group', f, vals)
  end

  def selected(f, vals)
    opt = f.targets.detect{|ff| vals.include?(ff)} if vals && vals.any?
    opt.id if opt
  end

  ##############################################################################

  def select_field_group(f, vals)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.options, selected: selected(f, vals)}
  end

  def field_set_group(f, vals)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected(f, vals)}
  end

  def build_field_set_group(fields, vals)
    fields.map{|f| build_field(f, vals)}
  end

  def select_menu_group(f, vals)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected(f, vals)} #maybe use f.kind for: label
  end

  def radio_button_group(f, vals)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind)} #maybe use f.kind for: label
  end

  #tags ########################################################################

  def number_field_group(f, vals)
    h={render_as: f.type.underscore, label: labelize(f), method: name_method(f)}
  end

  def text_field_group(f, vals)
    h={render_as: f.type.underscore, label: labelize(f), method: name_method(f)}
  end

  ##############################################################################

  def labelize(f)
    label = delim_format(words: f.field_name, split_delims: ['_'])
    if render_types.include?(f.type.underscore)
      label
    elsif f.kind == 'dimension'
      reject_words(label, %w[material mounting])
    end
  end

  def name_method(f)
    if render_types.include?(f.type.underscore)
      fk_id(f.kind)
    else
      delim_format(words: f.field_name, join_delim: '_', split_delims: [' ', '-'])
    end
  end

  #might want to kill these ####################################################

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
