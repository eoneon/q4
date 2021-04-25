module Context

  def class_cascade(store) #kind/Medium
    store = subclasses.each_with_object(store) do |class_b, store| #f_type
      class_b.subclasses.each do |class_c| #subkind
        class_c.subclasses.each do |class_d| #f_name
          class_b.cascade_build(self, class_b, class_c, class_d, store)
        end
      end
    end
  end

  def const
    to_s.split('::')[-1]
  end

  def to_class(f_type)
    f_type.to_s.classify.constantize
  end

  def dig_fields(target_sets, store)
    target_sets.map{|f_keys| store.dig(*f_keys)}.flatten
  end

  def method_exists?(method)
    methods(false).include?(method)
  end

end

# def targets(opts, f_kind, f_type)
#   opts.map{|key| [f_kind, f_type, key].map(&:to_sym)}
# end
