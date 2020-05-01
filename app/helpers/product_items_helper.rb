module ProductItemsHelper
  def types(klass)
    klass.file_set[1..-1].map{|assoc| assoc.camelize}
  end

  def fk_id(assoc)
    [assoc.singularize, 'id'].join("_")
  end

  def type_options(p_item, assoc)
    type_options = str_to_class(assoc).all - [p_item]
    #type_options if type_options.any?
  end

  #we can filter each assoc's collection using: scope = obj.tags[[assoc.singularize, "scope"].join("_")]
  #assoc.singularize.classify.constantize.where("tags -> ")

  def scoped_assoc(obj, assoc)
    k = scope_tag(assoc)
    v = obj.tags[k]
    str_to_class(assoc).where("tags -> \'#{k}\' = \'#{v}\'")
  end

  def str_to_class(str)
    str.singularize.classify.constantize
  end

  def scope_tag(str)
    [str.singularize, 'scope'].join('_')
  end
end
