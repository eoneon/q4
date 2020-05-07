module ProductItemsHelper
  def types(klass)
    klass.file_set[1..-1].map{|assoc| assoc.camelize}
  end

  def form_scope(obj)
    obj.to_superclass_name.underscore.to_sym
  end

  def fk_id(assoc)
    [assoc.singularize, 'id'].join("_")
  end

  def type_options(p_item, assoc)
    type_options = str_to_class(assoc).all - [p_item]
  end

  def item_hsh(assoc)
    if product_item_hsh(assoc)
      h={label: "#{assoc.singularize}-type", name_method: :item_name}
    else
      h={label: "#{assoc.singularize}", name_method: :field_name}
    end
  end

  def product_item_hsh(assoc)
    ProductItem.file_set.include?(assoc.singularize)
  end

  def name_method(obj)
    obj.to_superclass == ProductItem ? obj.item_name : obj.field_name
  end

  #we can filter each assoc's collection using: scope = obj.tags[[assoc.singularize, "scope"].join("_")]
  #assoc.singularize.classify.constantize.where("tags -> ")

  # def scoped_assoc(obj, assoc)
  #   k = scope_tag(assoc)
  #   v = obj.tags[k]
  #   str_to_class(assoc).where("tags -> \'#{k}\' = \'#{v}\'")
  # end
  #
  def str_to_class(str)
    str.singularize.classify.constantize
  end
  #
  # def scope_tag(str)
  #   [str.singularize, 'scope'].join('_')
  # end

  def folder_name(item_group)
    item_group.origin_type.underscore.pluralize
  end
end
