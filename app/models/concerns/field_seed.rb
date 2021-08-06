require 'active_support/concern'

module FieldSeed
  extend ActiveSupport::Concern

  class_methods do
    # Material.build_and_store(:targets, {})
    # BUILD METHODS ############################################################
    ############################################################################
    def build_and_store(m, store)
      desc_select(m: m).each_with_object(store){|c, store| c.field_group(m,store)}
    end

    def field_group(m, store)
      field_data(m).each_with_object(store) do |f_hsh, store|
        kind, type, f_name = [:kind,:type,:f_name].map{|k| f_hsh[:attrs][k].to_sym}
        add_field_and_merge(to_class(type), kind, type, f_name, f_hsh[:tags], f_hsh[:targets], store)
      end
    end

    def field_data(m)
      desc_select(m: m).each_with_object([]) do |c, f_set|
        f_attrs = c.build_attrs(:attrs)
        tags = [c.asc_select_merge(:name_values, f_attrs).reject{|k,v| v.blank?}, c.asc_select_merge(:admin_attrs,f_attrs)].each_with_object({}) {|h,tags| tags.merge!(h)}
        targets = build_targets(c, c.targets, f_attrs[:kind], c.asc_detect(:target_tags, :respond_to?))
        f_set.append({attrs: f_attrs, tags: tags, targets: targets})
      end
    end

    def build_targets(c, targets, k, target_tags)
      !target_tags ? targets : targets.each_with_object([]){|f_name,a| a.append([f_name, k, c.asc_select_merge(:target_tags, f_name).reject{|k,v| v.blank?}].compact)}
    end

    # def build_targets(c, targets, k, target_tags)
    #   return targets if !target_tags
    #   # puts "targets!!!!! #{targets}"
    #   # puts "c!!!!! #{c}"
    #   targets.each_with_object([]) do |f_name,a|
    #     #puts "f_name!!!!! #{f_name}"
    #     a.append([f_name, k, c.asc_select_merge(:target_tags, f_name).reject{|k,v| v.blank?}].compact)
    #   end
    # end

    # CRUD METHODS #############################################################
    def add_field_and_merge(f_class, kind, type, f_name, tags, targets, store)
      f_obj = add_field(f_class, f_name.to_s, kind.to_s, tags)
      f_obj.add_and_assoc_targets(targets) if targets
      case_merge(store, f_obj, kind, type, f_name)
    end

    def add_field(f_class, f_name, kind, tags=nil)
      f = f_class.where(field_name: f_name, kind: kind).first_or_create
      f.update_tags(tags)
      f
    end

    ############################################################################

    def build_attrs(m)
      asc_select_merge(m).each_with_object({}) do |(attr,idx), h|
        h.merge!({attr => const_tree[idx]})
      end
    end

    def asc_select_concat(m)
      asc_select(m).map{|c| c.public_send(m)}.flatten
    end

    ############################################################################

    def tag_keys
      (item_tags+search_tags).map(&:to_s)
    end

    def item_tags
      [:art_type, :art_category, :item_type, :item_category, :medium, :material]
    end

    def search_tags
      [:category_search, :medium_search, :material_search]
    end

    ############################################################################

    def dig_and_assoc(f, targets, store)
      dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
    end

    def build_target_group(f_names, f_type, f_kind)
      f_names.map{|f_name| [f_type, f_kind, f_name]}
    end

    def end_keys(t, *f_names)
      f_names.map{|f_name| [t,f_name]}
    end

  end
end

##############################################################################
##############################################################################

# def field_group(m, store)
#   field_data(m).each_with_object(store) do |f_hsh, store|
#     kind, type, f_name = [:kind,:type,:f_name].map{|k| f_hsh[:attrs][k].to_sym}
#     add_field_and_merge(to_class(type), kind, type, f_name, f_hsh[:tags], f_hsh[:targets], store)
#     #merge_origin(f_hsh[:origin], :origin, kind, type, f_name, store)
#     #merge_assocs(f_hsh[:assocs], :assocs, kind, type, f_name, store)
#   end
# end

##############################################################################
##############################################################################

# def merge_origin(origin, k, kind, type, f_name, store)
#   case_merge(store, origin, k, kind, type, f_name) if origin&.any?
# end
#
# def merge_assocs(assoc_set, k, kind, type, f_name, store)
#   assoc_set.each_with_object(store) {|assoc, store| case_merge(store, [f_name], k, kind, type, assoc)} if assoc_set&.any?
# end

# def product_vals(p, tag)
#   p.select{|f| f.tags&.has_key?(tag)}
# end

############################################################################
############################################################################

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

#p_hsh: p_hsh, a_hsh: assoc_hsh[a_key], assocs: h[:assocs]
# def assign_set_or_group(p_hsh, a_key, a_hsh, assocs)
#   assocs.each_with_object(p_hsh) do |assoc, p_hsh|
#     if a_hsh&.has_key?(assoc)
#       a_key == :set ? a_hsh[assoc].map{|f| p_hsh[a_key].append(f)} : p_hsh[a_key] << a_hsh[assoc]
#     end
#   end
# end
