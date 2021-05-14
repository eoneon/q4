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

  def const_tree
    to_s.split('::')
  end

  def class_tree(n,n2)
    (n..n2).map{|i| const_tree[0..i].join('::').constantize}.reverse
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

end

# def targets(opts, f_kind, f_type)
#   opts.map{|key| [f_kind, f_type, key].map(&:to_sym)}
# end

# def class_cascade(store) #kind/Medium
#   store = subclasses.each_with_object(store) do |class_b, store| #f_type
#     class_b.subclasses.each do |class_c| #subkind
#       class_c.subclasses.each do |class_d| #f_name
#         class_b.cascade_build(self, class_b, class_c, class_d, store)
#       end
#     end
#   end
# end



# def f_attrs(k)
#   attr_set[k].map{|i| const_tree[i]}
# end

# def attr_set
#   {a: [1, 2, 3], b: [0, 1, 2, 3]}
# end

######################
# def class_cascade(store:, class_set: [])
#   class_set.append(self)
#
#   if subclasses.any?
#     get_subclasses(store, subclasses, class_set)
#     #puts "class_set: #{class_set}"
#   else
#     cascade_build(store, class_set)
#   end
# end

# def get_subclasses(store, class_set)
#   store = subclasses.each_with_object(store) do |klass, store|
#     class_cascade(store, class_set.append(klass))
#   end
# end

# def get_subclasses(store, subclasses, class_set)
#   class_set = subclasses.each_with_object(class_set) do |subklass, class_set|
#     subklass.class_cascade(store: store, class_set: class_set)
#   end
# end
######################

# def const(i=-1)
#   to_s.split('::')[i]
# end

######################
