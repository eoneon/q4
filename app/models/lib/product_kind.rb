module ProductKind
  extend Context
  #a = ProductKind.product_seed
  # def self.product_seed
  #   products = [FlatArt].each_with_object([]) do |klass, products|
  #     products << klass.class_cascade(FieldKind.field_group)
  #   end
  # end

  ##############################################################################
  def build_product_group(store)
    p_set = uncombined_product_set(store)
    # puts "p_set: #{p_set}"
    format_set(combine_set(split_group_by_attr(p_set.flatten, :kind)))
  end
  ##############################################################################

  def uncombined_product_set(store)
    p_set = merged_assocs_from_class_tree.each_with_object([]) do |(k, f_hsh), p_set|
      f_hsh.each do |f_type, f_names|
        p_set << build_opts(f_names, k, f_type).map{|keys| store.dig(*keys)}.flatten
      end
    end
  end

  def combine_set(p_set)
    if p_set.detect{|a| a.count > 1}
      p_set[0].product(*p_set[1..-1])
    else
      p_set.map{|a| a[0]}
    end
  end

  def format_set(p_set)
    p_set.map{|a| a.group_by(&:kind).transform_values!{|v| v[0]}.transform_keys{|k| k.to_sym}}
  end

  def split_group_by_attr(set, attr)
    set.group_by(&attr).values
  end

  ##############################################################################

  def merged_assocs_from_class_tree
    p_group = filtered_class_tree(0,2,:assocs).each_with_object({}) do |c, p_group|
      c.assocs.each do |k, mod|
        mod.assocs.each do |f_type, f_names|
          merge_assocs(k, f_type, f_names, p_group)
        end
      end
    end
  end

  def merge_assocs(k, f_type, f_names, p_group)
    if p_group.dig(k, f_type)
      p_group.dig(k, f_type) + f_names
    else
      merge_assoc(Item.dig_set(k: f_type, v: f_names, dig_keys: [k]), p_group)
    end
  end

  def merge_assoc(dig_set, store)
    Item.param_merge(params: store, dig_set: dig_set)
  end

  ##############################################################################

end #end ProductKind
