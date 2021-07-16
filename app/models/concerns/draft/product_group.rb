require 'active_support/concern'

module ProductGroup
  extend ActiveSupport::Concern

  def pg_hsh
    store, product = {'params'=> {}, 'inputs' =>{}}, self.product
    return store if !product

    selected_params, product_params = fieldable_params, product.fieldable_params

    product_fields.each do |kind, field_val|
      parse_target(kind, field_val, selected_params, store)
    end

    store
  end

  def parse_target(kind, field_val, selected_params, store)
    if field_set_arr?(field_val)
      parse_nested_targets(kind, field_val, selected_params, store)
    elsif nested_kind?(field_val)
      parse_kind_hsh(kind, field_val, selected_params, store)

    elsif select_field?(field_val)
      select_field_store(kind, field_val, field_val.fieldables, selected_params.dig(kind), store)

    elsif select_menu?(f)
      select_menu_store(kind, field_val, selected_params.dig(kind), store)
    elsif field_set?(f)
      field_set_store(kind, field_val, selected_params.dig(kind), store)
    end
  end

  def parse_nested_targets(kind, field_vals, selected_params, store)
    field_vals.each do |field_val|
      parse_target(kind, field_val, selected_params, store)
    end
    store
  end

  def select_field_store(kind_key, f, opts, selected, store)
    selected = detect_selected(opts, selected)
    store['params'].merge!({kind_key => kind_params(f, selected)}) #consider how we add/remove assoc inside controller
    store['inputs'].merge!({kind_key => select_hsh(f, opts, selected)})
  end

  def kind_params(f, selected)
    selected ? {render_as(selected) => {field_key(f) => selected}} : {}
  end

  ##############################################################################
  #opts: field.fieldables, field: f, kind: kind, selected: selected_params.dig(kind)
  def detect_selected(opts, selected)
    return selected if !selected
    opts.detect{|opt| opt == selected}
  end

  #field.fieldables.detect{|f| selected_params[field.kind].include?(f)}
  ##############################################################################
  #store['params'].merge!({k =>{format_fkey(v) => item_fields.dig(k)}})
  # def field_type_key(f)
  #   f.type.underscore
  # end

  def field_key(f)
    f.field_name.downcase.split(' ').join('_')
  end

  def select_hsh(f, opts, selected)
    {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: opts, selected: selected}
  end

  def store_hsh(f,k,v)
    {render_as: render_as(f), label: f.field_name, method: k, selected: v}
  end

  def render_as(f)
    f.type.underscore
  end

  def fk_id(word)
    [word.singularize, 'id'].join("_")
  end

  ##############################################################################

  def field_set_arr?(f)
    f.class == Array
  end

  def nested_kind?(f)
    f.class == Hash
  end

  def field_set?(f)
    f.class == FieldSet
  end

  def select_field?(f)
    f.class == SelectField
  end

  def select_menu?(f)
    f.class == SelectMenu
  end

  def input_field?(f)
    [NumberField, TextField, TextAreaField].include?(f.class)
  end

  class_methods do

  end
end

#store['params'].merge!({k=>{'option'=> item_fields.dig(k)}})
#store['inputs'].merge!({k=> sselect_hsh(v,item_fields.dig(k))})

# def item_product
#   store={'params'=> {}, 'inputs' =>{}}
#   return store if !product
#   grouped_hsh = grouped_fieldables
#
#   grouped_hsh['product'].each do |kind, kind_hsh|
#     key_set=[]
#     nested_field_items(kind, kind_fields, grouped_hsh['item'][kind], store, key_set.append(k))
#   end
# end



# def item_product(store: {'params'=> {}, 'inputs' =>{}})
#   return store if !product
#   grouped_hsh = grouped_fieldables
#
#   grouped_hsh['product'].each do |kind, kind_fields|
#     key_set=[]
#     nested_field_items(kind, kind_fields, grouped_hsh['item'][kind], store, key_set.append(k))
#   end
# end
#
# def nested_field_items(kind_fields, scoped_item_fields, store, key_set)
#   kind_fields.each do |f|
#     update_store(f, kind_fields, scoped_item_fields, store, key_set)
#   end
# end
#
# def update_store(f, kind_fields, scoped_item_fields, store, key_set)
#   if f.class.method_defined?(:field_items)
#     route_by_field_type(f, detect_option(scoped_item_fields, kind_fields), scoped_item_fields, store, key_set)
#     # field_set or select_menu/select_field
#     # store['inputs'].merge!({k=>select_hsh(f,val)})
#   end
# end
#
# def route_by_field_type(f, v, scoped_item_fields, store, key_set)
#   if f.type == 'Fieldset'
#     nested_field_items(f.field_items, scoped_item_fields, store, key_set.append(f.type.underscore))
#   else
#     store['inputs'].dig(*key_set) << select_hsh(f,v)
#     #store['params']
#     # store['inputs'].merge!({k=>select_hsh(f,val)})
#   end
# end
#
# def update_input(input_hsh)
# end
#
# ##############################################################################
#
# def grouped_fieldables
#   [%w[item product], [fieldables, product.fieldables].map{|fields| fields.group_by{|f| f.kind}}].transpose.to_h if product
# end
#
# def detect_option(options, set)
#   options.detect{|i| set.include?(i)}
# end
#
# def key_type
#   {'SelectField'=>'options'}
# end
