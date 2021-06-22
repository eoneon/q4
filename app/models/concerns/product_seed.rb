require 'active_support/concern'

module ProductSeed
  extend ActiveSupport::Concern

  class_methods do
    # a = StandardFlatArt.build_product_group(h)
    def build_product_group(store)
      #origin, assocs, tag_keys = origin_hsh(store[:origin],store), assocs_hsh(:assocs, store)[:assocs], tag_sets.map(&:to_s)
      origin, assocs, tag_keys = origin_hsh(store[:origin],store), assocs_hsh(:assocs, store)[:assocs], (item_tags+search_tags).map(&:to_s)
      origin.each_with_object([]) do |p_hsh, set|

        p_hsh = push_one_or_many(p_hsh, assoc_fields(assocs, p_hsh[:assocs]))
        combine_fields(p_hsh).each do |p|
          p = build_product(sort_fields(p.group_by(&:kind)), tag_keys)
          set.append(p)
        end
      end
    end

    def build_product(p,tag_keys)
      {product_name: build_product_name(p), tags: build_product_tags(p, tag_keys)}
    end

    def build_product_name(p, tag='product_name')
      p.select{|f| f.tags&.has_key?(tag)}.map{|f| f.tags[tag]}.join(' ')
    end

    # def build_product_tags(p, tag_keys)
    #   tag_keys.each_with_object({}) do |tag_key, tags|
    #     p.map{|f| tags.merge!({tag_key.to_s => f.tags[tag_key.to_s]}) if f.tags&.has_key?(tag_key.to_s)}
    #   end
    # end

    def build_product_tags(p, tag_keys, tags={})
      tag_keys.each_with_object(tags) do |tag_key, tags|
        p.map{|f| tags.merge!({tag_key.to_s => f.tags[tag_key.to_s]}) if f.tags&.has_key?(tag_key.to_s)}
      end
    end

    def push_one_or_many(p_hsh, fields)
      fields.group_by(&:kind).values.each_with_object(p_hsh) do |a, p_hsh|
        a.one? ? p_hsh[:set] << a[0] : p_hsh[:group] << a
      end
    end

    def assoc_fields(h, assocs)
      assocs.each_with_object([]) {|assoc, fields| h[assoc].map{|f| fields.append(f)}}
    end

    def combine_fields(p_hsh)
      if p_hsh[:group].any?
        [p_hsh[:f]].product(*p_hsh[:group]).map{|a| a + p_hsh[:set]}
      else
        [p_hsh[:set].append(p_hsh[:f])]
      end
    end
    ############################################################################
    def origin_hsh(o_hsh, store)
      dig_keys_with_end_val(o_hsh).each_with_object([]) do |vals, set|
        set.append({f: store.dig(*vals[0..-2]), set:[], group:[], assocs: vals[-1]})
      end
    end

    def assocs_hsh(k, store)
      dig_keys_with_end_val(store[k]).each_with_object({}) do |vals, h|
        assoc, f_names = vals.pop(2)
        f_names.map{|f_name| case_merge(h, [store.dig(*vals[0..1].append(f_name))], k, assoc)}
      end
    end

    def push_one_or_many(p_hsh, fields)
      fields.group_by(&:kind).values.each_with_object(p_hsh) do |a, p_hsh|
        a.one? ? p_hsh[:set] << a[0] : p_hsh[:group] << a
      end
    end
    ############################################################################
    def tag_sets
      class_group('FieldGroup').each_with_object([]) do |c, set|
        if klass = c.desc_select(test_m: :respond_to?, m: :tag_meths)&.first
          klass.tag_meths.map{|tag| set.append(tag) if set.exclude?(tag) && tag != :product_name}
        end
      end
    end

    def sort_fields(p_hsh)
      p_set = field_order.each_with_object([]) {|k, p_set| p_set.append(p_hsh[k]) if p_hsh.has_key?(k)}
      p_set.flatten
    end

    def field_order
      %w[Embellishing Category Medium Material Leafing Remarque Numbering Signature TextBeforeCOA Certificate TextAfterTitle]
    end

  end
end
