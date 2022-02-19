module ProductItemsHelper
  # def types(klass)
  #   klass.file_set[1..-1].map{|assoc| assoc.camelize}
  # end
  #
  # def form_scope(obj)
  #   obj.base_type.underscore.to_sym #obj.class.base_class.to_s.underscore.to_sym
  # end
  #
  # def type_options(p_item, assoc)
  #   str_to_class(assoc).all - p_item.scoped_target_collection(assoc) - [p_item]
  # end
  #
  # def item_hsh(assoc)
  #   if product_item_hsh(assoc)
  #     {label: "#{assoc.singularize}-type", name_method: :item_name}
  #   else
  #     {label: "#{assoc.singularize}", name_method: :field_name}
  #   end
  # end
  #
  # def product_item_hsh(assoc)
  #   ProductItem.file_set.include?(assoc.singularize)
  # end
  #
  # def name_method(obj)
  #   obj.class.base_class == ProductItem ? obj.item_name : obj.field_name #obj.to_superclass == ProductItem ? obj.item_name : obj.field_name
  # end
  #
  # def str_to_class(str)
  #   str.singularize.classify.constantize
  # end
  #
  # def target_folder(target)
  #   target.class.base_class.to_s.underscore.pluralize
  # end
end
