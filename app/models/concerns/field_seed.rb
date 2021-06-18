require 'active_support/concern'

module FieldSeed
  extend ActiveSupport::Concern
  # h = FieldItem.seed_fields
  # a = Medium.build_product_group(h)
  # Medium.assoc_hsh(:set, h)
  class_methods do


    # BUILD METHODS ############################################################ set = Medium.assoc_hsh(:set, h)
    ############################################################################
    def build_and_store(m, store)
      desc_select(m: m).each_with_object(store){|c, store| c.field_group(m,store)}
    end

    def field_group(m, store)
      field_data(m).each_with_object(store) do |f_hsh, store|
        kind, type, f_name = [:kind,:type,:f_name].map{|k| f_hsh[:attrs][k].to_sym}
        add_field_and_merge(to_class(type), kind, type, f_name, f_hsh[:tags], f_hsh[:targets], store)
        merge_origin(f_hsh[:origin], :origin, kind, type, f_name, store)
        merge_assocs(f_hsh[:assocs], :assocs, kind, type, f_name, store)
      end
    end

    def field_data(m)
      desc_select(m: m).each_with_object([]) do |c, f_set|
        attrs = c.build_attrs(:attrs)
        f_set.append({attrs: attrs, tags: c.build_tags(attrs), origin: c.build_assoc(:origin), assocs: c.build_assoc(:assocs), targets: c.targets})
      end
    end

    def merge_origin(origin, k, kind, type, f_name, store)
      case_merge(store, origin, k, kind, type, f_name) if origin&.any?
    end

    def merge_assocs(assoc_set, k, kind, type, f_name, store)
      assoc_set.each_with_object(store) {|assoc, store| case_merge(store, [f_name], k, kind, type, assoc)} if assoc_set&.any?
    end

    # CRUD METHODS #############################################################
    def add_field_and_merge(f_class, kind, type, f_name, tags, targets, store)
      f_obj = add_field(f_class, f_name.to_s, kind.to_s, tags)
      f_obj.add_and_assoc_targets(targets) if targets
      case_merge(store, f_obj, kind, type, f_name)
    end

    def add_field(f_class, f_name, kind, tags=nil)
      f = f_class.where(field_name: f_name, kind: kind).first_or_create
      update_tags(f, tags)
      f
    end

    def update_tags(f, tags)
      return if tags.blank? || tags.stringify_keys == f.tags
      f.tags = assign_or_merge(f.tags, tags.stringify_keys)
      f.save
    end
    ############################################################################

    ############################################################################

    def build_attrs(m)
      merge_asc_selected_hash_methods(m).each_with_object({}) do |(attr,idx), h|
        h.merge!({attr => const_tree[idx]})
      end
    end

    def build_tags(args)
      return unless respond_to?(:tag_meths)
      asc_detect_with_methods(tag_meths).each_with_object({}) do |(m,c), tags|
        tags.merge!({m => c.public_send(m, args)})
      end
    end

    def build_assoc(assoc_meth)
      asc_select(assoc_meth).map{|c| c.public_send(assoc_meth)}.flatten
    end

    ############################################################################

    def assign_or_merge(h, h2)
      h.nil? ? h2 : h.merge(h2)
    end

    ##############################################################################
    ##############################################################################

    def dig_and_assoc(f, targets, store)
      dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
    end

    def build_target_group(f_names, f_type, f_kind)
      f_names.map{|f_name| [f_type, f_kind, f_name]}
    end

  end
end

# def product_fields(store)
#   set, group = [:set, :group].map{|assoc| assoc_hsh(assoc, store)}
#   tag_keys = tag_sets.map(&:to_s)
#   products = combine_fields(origin_hsh(store[:origin], store), set.merge(group))
#   products.each_with_object([]) do |p,set|
#     p = sort_fields(p.group_by(&:kind)).flatten
#     product_name = product_vals(p, 'product_name').map{|f| f.tags['product_name']}.join(' ') # (&:strip).join(' ')
#     tags = product_tags(p, tag_keys)
#     set.append({product_name: product_name, tags: tags})
#     #tags = %w[medium_attr material_attr].map{|tag_key| [tag_key, product_vals(p,tag).tags[tag_key]]}.to_h
#     #search = product_vals(p, 'search').map{|f| ["#{f.kind}_search", f.tags['search']]}.to_h
#   end
# end

# def product_vals(p, tag)
#   p.select{|f| f.tags&.has_key?(tag)}
# end

# def sort_fields(p)
#   p_set = field_order.each_with_object([]) do |k, p_set|
#     p_set << p[k] if p.has_key?(k)
#   end
# end

# def sort_fields(p)
#   p_set = field_order.each_with_object([]) {|k, p_set| p_set.append(p[k]) if p.has_key?(k)}
#   p_set.flatten
# end

# def field_order
#   %w[Embellishing Category Medium Material Leafing Remarque Numbering Signature TextBeforeCOA Certificate TextAfterTitle]
# end
#
# def product_tags(p, tag_keys)
#   tag_keys.each_with_object({}) do |tag_key, tags|
#     p.each do |f|
#       tags.merge!({tag_key.to_s => f.tags[tag_key.to_s]}) if f.tags&.has_key?(tag_key.to_s)
#     end
#   end
# end

# def tag_sets
#   class_group('FieldGroup').each_with_object([]) do |c, set|
#     if klass = c.desc_select(test_m: :respond_to?, m: :tag_meths)&.first
#       klass.tag_meths.map{|tag| set.append(tag) if set.exclude?(tag) && tag != :product_name}
#     end
#   end
# end
############################################################################
############################################################################

# def combine_fields(origin, assoc_hsh)
#   origin.each_with_object([]) do |p_hsh,products|
#     p_hsh = assign_set_or_group(assoc_hsh, p_hsh[:assocs], p_hsh)
#     if p_hsh[:group].any?
#       group = p_hsh[:group].flatten.group_by(&:kind).values
#       [p_hsh[:f]].product(*group).map{|a| a + p_hsh[:set]}.map{|p| products.append(p)}
#     else
#       products.append(p_hsh[:set].append(f))
#     end
#   end
# end
#
# def assign_set_or_group(assoc_hsh, assocs, p_hsh)
#   assocs.each_with_object(p_hsh) do |k, p_hsh|
#     if assoc_hsh[:set].has_key?(k)
#       assoc_hsh[:set][k].map{|f| p_hsh[:set].append(f)}
#     elsif assoc_hsh[:group].has_key?(k)
#       p_hsh[:group] << assoc_hsh[:group][k]
#     end
#   end
# end

# def origin_hsh(o_hsh, store)
#   dig_keys_with_end_val(o_hsh).each_with_object([]) do |vals, set|
#     set.append({f: store.dig(*vals[0..-2]), set:[], group:[], assocs: vals[-1]})
#   end
# end

# def assoc_hsh(assoc, store)
#   dig_keys_with_end_val(store[assoc]).each_with_object({}) do |vals, a_hsh|
#     a_key, f_names = vals.pop(2)
#     f_names.map{|f_name| case_merge(a_hsh, [store.dig(*vals[0..1].append(f_name))], assoc, a_key)}
#   end
# end


# def attrs_tags_and_assocs(m)
#   desc_select(m: m).each_with_object([]) do |c, set|
#     attrs = c.build_attrs(:attrs)
#     set.append({attrs: attrs, tags: c.build_tags(attrs), assocs: c.build_assocs(:origin, :set, :group), targets: c.targets})
#   end
# end

# def build_assocs_and_merge(assocs, kind, type, f_name, store)
#   assocs.select{|k,v| !v.blank?}.each_with_object(store) do |(asc_m,set),store|
#     if asc_m == :origin
#       case_merge(store, set, asc_m, kind, type, f_name)
#     else
#       set.map {|a_key| case_merge(store, [f_name], asc_m, kind, type, a_key)}
#     end
#   end
# end
##############################################################################
#STRING methods
##############################################################################

# def class_to_cap(class_word, skip_list=[])
#   class_word.underscore.split('_').map{|word| cap_word(word, skip_list)}.join(' ')
# end
#
# def cap_word(word, skip_list)
#   skip_list.include?(word) ? word : word.capitalize
# end
#
# def edit_name(name, edit_list)
#   name = edit_list.each_with_object(name) do |word_set|
#     name.sub!(word_set[0], word_set[1])
#   end
# end
#
# def edit_list
#   [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['Of One', ' 1/1']]
# end
#
# def format_name(name)
#   name.split(' ').map(&:strip).join(' ')
# end
#
# def indefinite_article(noun)
#   %w[a e i o u].include?(noun.first.downcase) && noun.split('-').first != 'one' || noun == 'HC' ? 'an' : 'a'
# end

# def products(origin_hsh, assoc_hsh, store)
#   dig_keys_with_end_val(origin_hsh).each_with_object([]) do |vals, products|
#     assocs = vals.pop
#     p_hsh = {set: [store.dig(*vals)], group:[]}
#     p_hsh = build_p_hsh(assoc_hsh, assocs, p_hsh)
#     [p_hsh[:set]].product(*p_hsh[:group]).map{|a| a.flatten}.map{|p| products.append(p)}
#   end
# end

# def combine_assocs(p_hsh, assoc_hsh, products)
#   assoc_hsh.each_with_object(products) do |(a_key, a_hsh), products|
#     p_hsh = assign_set_or_group(p_hsh, a_hsh, a_key, p_hsh[:assocs])
#     products << [p_hsh[:set]].product(*p_hsh[:group]).map{|a| a.flatten}.map{|p| products.append(p)}
#   end
# end

# def product_fields(store, set=[])
#   [:set, :group].map{|assoc| assoc_hsh(assoc, store)}.each_with_object(set) do |(a_key,a_hsh),set|
#     origin_hsh(store[:origin], store).each do |p_hsh|
#       #puts "a_key: #{a_key}, a_hsh: #{a_hsh}, p_hsh: #{p_hsh}" u = Medium.product_fields(h)
#       p_hsh = assign_set_or_group(p_hsh, a_key, a_hsh, p_hsh[:assocs])
#       if p_hsh[:group].any?
#         [p_hsh[:set]].product(*p_hsh[:group]).map{|a| a.flatten}.map{|p| set.append(p)}
#       else
#         set.append(p_hsh[:set])
#       end
#     end
#   end
# end

#p_hsh: p_hsh, a_hsh: assoc_hsh[a_key], assocs: h[:assocs]
# def assign_set_or_group(p_hsh, a_key, a_hsh, assocs)
#   assocs.each_with_object(p_hsh) do |assoc, p_hsh|
#     if a_hsh&.has_key?(assoc)
#       a_key == :set ? a_hsh[assoc].map{|f| p_hsh[a_key].append(f)} : p_hsh[a_key] << a_hsh[assoc]
#     end
#   end
# end

# def add_field_group(f_class, member_class, f_type, f_kind, f_name, store, tags=nil)
#   f = add_field(f_class, f_name, f_kind, tags)
#   f.add_and_assoc_targets(member_class.targets) if member_class.targets
#   case_merge(store, f_name.to_sym, f, f_kind.to_sym, f_type.to_sym)
# end

# def merge_enum(desc_m, asc_m, *dig_keys)
#   desc_select_asc_detect_and_call(desc_m, asc_m, :respond_to?).each_with_object({}) do |(c,set),h|
#     kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
#     set.map {|k| case_merge(h,k,[c], asc_m, kind, type)}
#   end
# end


#c.public_send(asc_meth).map {|k| (h.has_key?(k) ? h[k].append(c.const) : h[k] = [c.const])}

# def merge_enum(desc_meth, asc_meth)
#   desc_select_then_asc_detect(desc_meth, asc_meth).each_with_object({}) do |c, h|
#     #c.public_send(asc_meth).map {|k| (h.has_key?(k) ? h[k].append(c.const) : h[k] = [c.const])}
#     c.public_send(asc_meth).each {|k| case_merge(h,k,[c.const])}
#   end
# end

# def merge_enum(desc_meth, asc_meth)
#   desc_select_then_asc_detect(desc_meth, asc_meth).each do |c|
#     #c.public_send(asc_meth).map {|k| (h.has_key?(k) ? h[k].append(c.const) : h[k] = [c.const])}
#     c.public_send(asc_meth).each_with_object(h) {|k| case_merge(h,k,[c.const])}
#   end
# end

############################################################################
# def merge_groups
#   desc_select_classes(:method_exists?, :targets).each_with_object({}) do |c, h|
#     c.asc_detect_and_call(:group).each_with_object(h){|k| merge_hash_set(h, k, c.const)}
#   end
# end

# def merge_hash_set(h, k, v)
#   h.has_key?(k) ? h[k].append(v) : h[k] = [v]
# end

# def collect_assocs(c, h)
#   c.group.each_with_object(h){|k| merge_hash_set(k, c.const, h)}
# end
# def self.field_group
#   store = [Authentication, Category, Detail, Dimension, Disclaimer, GartnerBlade, LimitedEdition, Material, Medium, Mounting, Sculpture, Submedium].each_with_object({}) do |klass, store|
#     klass.class_cascade(store)
#   end
# end

# def build_tags(args:, tag_set:, class_set:)
#   tags = tag_set.each_with_object({}) do |meth, tags|
#     if klass = class_set.detect{|c| c.method_exists?(meth)}
#       tags.merge!({meth.to_s => klass.public_send(meth, *args.values)})
#     end
#   end
# end
