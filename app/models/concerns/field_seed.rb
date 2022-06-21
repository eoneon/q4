require 'active_support/concern'

module FieldSeed
  extend ActiveSupport::Concern

  class_methods do

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

############################################################################
#f.tags&.has_key?(tag)}
############################################################################
