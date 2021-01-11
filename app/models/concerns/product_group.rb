require 'active_support/concern'

module ProductGroup
  extend ActiveSupport::Concern

  def item_product
    store={'params'=> {}, 'inputs' =>{}}
    return store if !product
    grouped_hsh = scoped_field_items_grouped_by_kind

    grouped_hsh['product'].each do |kind, kind_hsh|
      key_set=[]
      nested_field_items(kind, kind_fields, grouped_hsh['item'][kind], store, key_set.append(k))
    end
  end

  def nested_field_items(kind_fields, scoped_item_fields, store, key_set)
    kind_fields.each do |f|
      update_store(f, kind_fields, scoped_item_fields, store, key_set)
    end
  end

  def update_store(f, kind_fields, scoped_item_fields, store, key_set)
    if f.class.method_defined?(:field_items)
      route_by_field_type(f, detect_option(scoped_item_fields, kind_fields), scoped_item_fields, store, key_set)
      # field_set or select_menu/select_field
      # store['inputs'].merge!({k=>select_hsh(f,val)})
    end
  end

  def route_by_field_type(f, v, scoped_item_fields, store, key_set)
    if f.type == 'Fieldset'
      nested_field_items(f.field_items, scoped_item_fields, store, key_set.append(f.type.underscore))
    else
      store['inputs'].dig(*key_set) << select_hsh(f,v)
      #store['params']
      # store['inputs'].merge!({k=>select_hsh(f,val)})
    end
  end

  def update_input(input_hsh)
  end

  ##############################################################################

  def scoped_field_items_grouped_by_kind
    [%w[item product], [fieldables, product.fieldables].map{|fields| fields.group_by{|f| f.kind}}].transpose.to_h if product
  end

  def detect_option(options, set)
    options.detect{|i| set.include?(i)}
  end

  def key_type
    {'SelectField'=>'options'}
  end

  ##############################################################################

  def pg_hsh
    store, product = {'params'=> {}, 'inputs' =>{}}, self.product
    return store if !product
    item_fields = nested_fieldables

    product.nested_fieldables.each do |k, v|
      parse_target(k, v, item_fields, store)
    end
    store
  end

  def parse_target(k, v, item_fields, store)
    if select_field?(v)
      select_field_store(k, v, item_fields.dig(k), store)
    # elsif field_set_arr?(f)
    #   parse_target(k, v, item_fields, store)
    end
  end

  def select_field_store(k, f, item_val, store)
    store['params'].merge!({k => { item_val.type.underscore => { format_fkey(f) => item_val } } })
    #store['params'].merge!({k=>{'option'=> item_val}})
    #store['inputs'].merge!({k=> sselect_hsh(v, item_val)})
  end

  ##############################################################################

  def field_set?(f)
    f.class == FieldSet
  end

  def field_set_arr?(f)
    f.class == Array
  end

  def nested_kind?(f)
    f.class == Hash
  end

  def select_field?(f)
    f.class == SelectField
  end

  def select_menu?(f)
    f.class == SelectMenu
  end

  def input?(f)
    [NumberField, TextField, TextAreaField].include?(f.class)
  end

  ##############################################################################
  #store['params'].merge!({k =>{format_fkey(v) => item_fields.dig(k)}})
  def format_fkey(f)
    f.field_name.split(' ').join('_')
  end

  def sselect_hsh(f,v)
    {render_as: render_as(f), label: f.field_name, method: fk_id(f.kind), collection: f, selected: v}
  end

  def render_as(f)
    f.type.underscore
  end

  def fk_id(word)
    [word.singularize, 'id'].join("_")
  end

  class_methods do

  end
end

#store['params'].merge!({k=>{'option'=> item_fields.dig(k)}})
#store['inputs'].merge!({k=> sselect_hsh(v,item_fields.dig(k))})
