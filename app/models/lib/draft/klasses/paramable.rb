module Paramable
  def add_field(f_class, f_name, kind)
    f_class.where(field_name: f_name, kind: kind).first_or_create
  end

  def merge_field(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
  end
end
