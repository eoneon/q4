module Context

  def class_cascade(store)
    if subclasses.any?
      cascade_subclasses(store)
    else
      cascade_build(store)
    end
  end

  def cascade_subclasses(store)
    subclasses.each do |klass|
      klass.class_cascade(store)
    end
  end

  ######################

  def f_attrs(*idxs)
    idxs.map{|i| const_tree[i]}
  end

  ######################
  def filtered_class_tree(n, n2, meth)
    class_tree(n,n2).select{|klass| klass.method_exists?(meth)}
  end

  def class_tree(n,n2)
    (n..n2).map{|i| const_tree[0..i].join('::').constantize}.reverse
  end

  def const_tree
    to_s.split('::')
  end

  def const(i=-1)
    const_tree[i]
  end

  ######################

  def to_class(f_type)
    f_type.to_s.classify.constantize
  end

  def dig_fields(target_sets, store)
    target_sets.map{|f_keys| store.dig(*f_keys)}.flatten
  end

  def detect_method(meth, class_set)
    class_set.detect{|c| c.method_exists?(meth)}
  end

  def method_exists?(method)
    methods(false).include?(method)
  end

  def build_opts(set, k, k2)
    set.map{|k3| [k, k2, k3]}
  end

end
