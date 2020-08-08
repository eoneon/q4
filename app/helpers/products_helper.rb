module ProductsHelper

  #kill
  def product_field_params(product, fields, item, vals, set=[])
    cascade_build(fields, vals, set)
  end

  ##############################################################################
  #product_fields
  # def cascade_build(fields, vals, set)
  #   fields.each do |f|
  #     if f.type == 'FieldSet'
  #       build_field_set_group(fields, vals, set)
  #     else
  #       cascade_build_f_hsh(f, vals, selected(f, vals), set)
  #     end
  #   end
  #   set
  # end
  #
  # def build_field_set_group(fields, vals, set)
  #   fields.each do |f|
  #     build_field(f, selected(f, vals).try(:id))
  #   end
  # end

  #kill #############################################################################

  def cascade_build(fields, vals, set)
    fields.each do |f|
      cascade_build_f_hsh(f, vals, selected(f, vals), set)
    end
    set
  end

  def cascade_build_f_hsh(f, vals, selected, set)
    #set << build_field(f, selected.try(:id))
    set << build_field(f, selected)
  end

  def build_field(f, selected)
    #public_send(f.type.underscore + '_group', f, selected_id)
    public_send(f.type.underscore + '_group', f, selected)
  end

  def build_field_set_group(fields, vals)
    #fields.map{|f| build_field(f, selected(f, vals).try(:id))}
    fields.map{|f| build_field(f, selected(f, vals))}
  end

  def selected(f, vals)
    f.targets.detect{|ff| vals.include?(ff)} if vals && vals.any?
  end

  ##############################################################################

  # def select_field_group(f, selected_id)
  #   h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.options, selected: selected_id}
  # end
  #
  # def field_set_group(f, selected_id)
  #   h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected_id}
  # end
  #
  # def select_menu_group(f, selected_id)
  #   h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected_id} #maybe use f.kind for: label
  # end
  #
  # def radio_button_group(f, selected_id)
  #   h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind)} #maybe use f.kind for: label
  # end

  #

  def select_field_group(f, selected)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.options, selected: selected}
  end

  def field_set_group(f, selected)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected}
  end

  def select_menu_group(f, selected)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind), collection: f.targets, selected: selected} #maybe use f.kind for: label
  end

  def radio_button_group(f, selected)
    h={render_as: f.type.underscore, label: f.field_name, method: fk_id(f.kind)} #maybe use f.kind for: label
  end

  #tags ########################################################################

  def number_field_group(f, selected)
    h={render_as: f.type.underscore, label: labelize(f), method: name_method(f)}
  end

  def text_field_group(f, selected)
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
