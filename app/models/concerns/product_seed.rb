require 'active_support/concern'

module ProductSeed
  extend ActiveSupport::Concern

  class_methods do

    def field_order
      [:Embellishing, :Category, :Medium, :Material, :Leafing, :Remarque, :Numbering, :Signature, :TextBeforeCOA, :Certificate, :TextAfterTitle]
    end

  end
end

# def build_product_group(store)
#   p_set = uncombined_product_set(store)
#   format_set(combine_set(split_group_by_attr(p_set.flatten, :kind)))
# end
# ##############################################################################
#
# def uncombined_product_set(store)
#   p_set = merged_assocs_from_class_tree.each_with_object([]) do |(k, f_hsh), p_set|
#     f_hsh.each do |f_type, f_names|
#       p_set << build_opts(f_names, k, f_type).map{|keys| store.dig(*keys)}.flatten
#     end
#   end
# end
#
# def combine_set(p_set)
#   if p_set.detect{|a| a.count > 1}
#     p_set[0].product(*p_set[1..-1])
#   else
#     p_set.map{|a| a[0]}
#   end
# end
#
# def format_set(p_set)
#   p_set.map{|a| a.group_by(&:kind).transform_values!{|v| v[0]}.transform_keys{|k| k.to_sym}}
# end
#
# def split_group_by_attr(set, attr)
#   set.group_by(&attr).values
# end
