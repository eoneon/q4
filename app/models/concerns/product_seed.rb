require 'active_support/concern'

module ProductSeed
  extend ActiveSupport::Concern

  class_methods do

    def product_group(store)
      select_end_classes.each do |c|
        fields = c.dig_product_fields(:assocs, store)
        origins, fields = split_set(fields, fields.select{|f| f.tags&.has_key?('origin')})
        combine_and_build(origins, fields, c.tag_keys, c.call_if(:product_name))
      end
    end

    def dig_product_fields(m,store)
      asc_select_merge(m).each_with_object([]) do |(kind,key_group), fields|
        key_group.map{|keys| keys.prepend(kind)}.map{|dig_keys| fields.append(store.dig(*dig_keys))}
      end
    end

    def combine_and_build(origins, fields, tag_keys, product_name)
      origins.each do |f|
        combine_fields(push_one_or_many({f: f, set:[], group:[]}, fields)).each do |p_fields|
          p_fields = sort_fields(p_fields.group_by(&:kind))
          build_product(p_fields, tag_keys, product_name)
        end
      end
    end

    def combine_fields(p_hsh)
      if p_hsh[:group].any?
        [p_hsh[:f]].product(*p_hsh[:group]).map{|a| a + p_hsh[:set]}
      else
        [p_hsh[:set].append(p_hsh[:f])]
      end
    end

    def push_one_or_many(p_hsh, fields)
      fields.group_by(&:kind).values.each_with_object(p_hsh) do |a, p_hsh|
        a.one? ? p_hsh[:set] << a[0] : p_hsh[:group] << a
      end
    end

    ############################################################################
    ############################################################################

    def build_product(p_fields, tag_keys, product_name)
      Product.builder(build_product_name(p_fields, product_name), p_fields, build_product_tags(p_fields, tag_keys))
    end

    def build_product_name(p_fields, product_name, tag='product_name')
      p_fields = p_fields.select{|f| f.tags&.has_key?(tag)}
      p_fields = p_fields.reject{|f| f.kind == 'Material'} if p_fields.detect{|f| f.tags.has_key?('paper_only')}
      p_fields.map{|f| f.tags[tag]}.prepend(product_name).compact.join(' ')
    end

    def build_product_tags(p, tag_keys)
      tag_keys.each_with_object({'product_type'=> const(0)}) do |tag_key, tags|
        p.map{|f| tags.merge!({tag_key.to_s => f.tags[tag_key.to_s]}) if f.tags&.has_key?(tag_key.to_s)}
      end
    end

    ############################################################################
    ############################################################################

    def split_set(set, subset)
      a, b = subset, (set-subset)
    end

    def sort_fields(p_hsh)
      p_set = field_order.each_with_object([]) {|k, p_set| p_set.append(p_hsh[k]) if p_hsh.has_key?(k)}
      p_set.flatten
    end

    def field_order
      %w[TextAfterTitle Embellishing Category Medium Material Submedium SculptureType Leafing Remarque Numbering Signature Authentication TextBeforeCOA Disclaimer]
    end

  end
end


# def origin_hsh(o_hsh, store)
#   dig_keys_with_end_val(o_hsh).each_with_object([]) do |vals, set|
#     set.append({f: store.dig(*vals[0..-2]), set:[], group:[], assocs: vals[-1]})
#   end
# end

# def assocs_hsh(k, store)
#   dig_keys_with_end_val(store[k]).each_with_object({}) do |vals, h|
#     assoc, f_names = vals.pop(2)
#     f_names.map{|f_name| case_merge(h, [store.dig(*vals[0..1].append(f_name))], k, assoc)}
#   end
# end
