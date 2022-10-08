require 'active_support/concern'

module FieldSeed
  extend ActiveSupport::Concern

  class_methods do

    # BUILD METHODS ############################################################
    ############################################################################
    def build_and_store(m, store)
      desc_select(m: m).each_with_object(store){|c, store| c.field_group(m,store)}
    end

    ##################################################################
    # START REFACTOR FOR FIELDSEED
    ##################################################################
    # def field_group(m, store)
    # 	field_data(m).each_with_object(store) {|f_hsh, store| add_field_and_merge(f_hsh[:attrs][:type], f_hsh[:attrs][:kind], f_hsh[:attrs][:field_name], f_hsh, store)}
    # end

    def field_group(m, store)
      field_data(m).each_with_object(store) do |f_hsh, store|
        puts "f_hsh=> #{f_hsh}"
        add_field_and_merge(f_hsh[:attrs][:type], f_hsh[:attrs][:kind], f_hsh[:attrs][:field_name], f_hsh, store)
        #add_field_and_merge(f_hsh[:type], f_hsh[:kind], f_hsh[:field_name], f_hsh, store)
      end
    end

    def field_data(m)
    	desc_select(m: m).each_with_object([]) {|c, f_set| f_set.append(config_target(c))}
    end

    def add_field_and_merge(type, kind, f_name, f_hsh, store)
    	f_obj = add_field(to_class(type), kind, f_name, f_hsh)
      puts "f_obj=> #{f_obj}"
    	add_and_assoc_targets(f_obj, f_hsh[:targets])
      puts "kind=> #{kind}, type=> #{type}, f_name=> #{f_name}"
    	case_merge(store, f_obj, kind.to_sym, type.to_sym, f_name.to_sym)
    end

    ## field_data methods           ######################################
    def config_target(c, f_hsh={})
    	f_hsh[:attrs] = c.build_attrs #(:attrs)
      puts "f_hsh[:attrs]=>#{f_hsh[:attrs]}"
      f_hsh[:tags] = c.build_parent_tags(f_hsh[:attrs])
      puts "f_hsh[:tags]=>#{f_hsh[:tags]}"
    	#f_hsh[:tags] = [c.asc_select_merge(:name_values, f_hsh[:attrs]).reject{|k,v| v.blank?}, c.asc_select_merge(:admin_attrs, f_hsh[:attrs])].each_with_object({}) {|h,tags| tags.merge!(h)}
    	#f_hsh[:targets] = build_targets(c, c.targets, f_hsh[:attrs][:kind], c.asc_detect(:target_tags, :respond_to?))
      f_hsh[:targets] = c.build_targets
      puts "f_hsh[:targets]=>#{f_hsh[:targets]}"
    	f_hsh[:assocs] = build_assocs(f_hsh[:targets])
    	f_hsh
    end

    def build_parent_tags(attrs)
      [asc_select_merge(:name_values, attrs).reject{|k,v| v.blank?}, asc_select_merge(:admin_attrs, attrs)].each_with_object({}) {|h,tags| tags.merge!(h)}
    end

    # def build_targets(c, targets, k, target_tags)
    #   puts "target_tags=>#{target_tags}"
    #   puts "targets=>#{targets}"
    #   puts "c=>#{c}"
    #
    # 	if target_tags
    # 		config_option_targets(target_tags.to_s.split('::')[0], targets, c, target_tags)
    # 	elsif targets
    # 		targets.map{|target| {type: target[0], kind: target[1], field_name: target[2]}}
    # 	end
    # end

    def build_targets
      if target_tags = asc_detect(:target_tags, :respond_to?)
        targets.map{|target| {type: 'Option', kind: target_tags.to_s.split('::')[0], field_name: target, tags: asc_select_merge(:target_tags, target).reject{|k,v| v.blank?}}}
      elsif targets
        targets.map{|target| {type: target[0], kind: target[1], field_name: target[2]}}
      end
    end

    # def build_targets
    #   if target_tags = asc_detect(:target_tags, :respond_to?)
    #     targets.map{|target| {type: 'Option', kind: target_tags.to_s.split('::')[0], field_name: target, tags: asc_select_merge(:target_tags, target).reject{|k,v| v.blank?}}}
    #   elsif targets
    #     targets.map{|target| {type: target[0], kind: target[1], field_name: target[2]}}
    #   end
    # end

    # def config_option_targets(kind, target_names, c, target_tags, type='Option')
    # 	target_names.map{|target_name| {type: type, kind: kind, field_name: target_name, tags: c.asc_select_merge(:target_tags, target_name).reject{|k,v| v.blank?}}}
    # end

    # def config_option_targets(kind, target_names, c, target_tags, type='Option')
    #   target_names.map{|target_name| {type: type, kind: kind, field_name: target_name, tags: c.asc_select_merge(:target_tags, target_name).reject{|k,v| v.blank?}}}
    # end

    def build_assocs(targets)
    	targets.each_with_object({}).each_with_index {|(f_hsh,assocs),i| assocs[i+1] = [:type, :kind, :field_name].map{|attr| f_hsh[attr]}.join("::")} if targets
    end
    ## end  field_data methods     ######################################

    ## add_field_and_merge methods ######################################

    def add_field(f_class, f_name, kind, f_hsh)
    	f = f_class.where(field_name: f_name, kind: kind).first_or_create
    	#f.update_hstores(f_hsh)
      f.tags = f_hsh[:tags] if f_hsh[:tags]
      f.assocs = f_hsh[:assocs] if f_hsh[:assocs]
      f.save if f_hsh[:tags] || f_hsh[:assocs]
    	f
    end

    # def update_hstores(f_hsh)
    # 	[:tags, :assocs].each do |hstore|
    #     if h = f_hsh[hstore]
    #       puts "h=>#{h}"
    #       puts "f_hsh[hstore]=>#{f_hsh[hstore]}"
    #       puts "self.public_send(hstore)=>#{self.public_send(hstore)}"
    #       self.public_send(hstore) = h
    #       self.save
    #     end
    #   end
    # end

    def add_and_assoc_targets(f, targets)
    	targets.map{|ff_hsh| add_field(to_class(ff_hsh[:type]), ff_hsh[:field_name], ff_hsh[:kind], ff_hsh)}.map{|ff| f.assoc_unless_included(ff)} if targets
    end
    ## end add_field_and_merge ######################################

    ##################################################################
    # END REFACTOR FOR FIELDSEED
    ##################################################################

    #replace
    # def field_group(m, store)
    #   field_data(m).each_with_object(store) do |f_hsh, store|
    #     kind, type, f_name = [:kind,:type,:f_name].map{|k| f_hsh[:attrs][k].to_sym}
    #     add_field_and_merge(to_class(type), kind, type, f_name, f_hsh[:tags], f_hsh[:targets], store)
    #   end
    # end
    #replace
    # def field_data(m)
    #   desc_select(m: m).each_with_object([]) do |c, f_set|
    #     f_attrs = c.build_attrs(:attrs)
    #     tags = [c.asc_select_merge(:name_values, f_attrs).reject{|k,v| v.blank?}, c.asc_select_merge(:admin_attrs, f_attrs)].each_with_object({}) {|h,tags| tags.merge!(h)}
    #     targets = build_targets(c, c.targets, f_attrs[:kind], c.asc_detect(:target_tags, :respond_to?))
    #     puts "targets=>#{targets}"
    #     f_set.append({attrs: f_attrs, tags: tags, targets: targets})
    #   end
    # end
    #replace
    # def build_targets(c, targets, k, target_tags)
    #   !target_tags ? targets : targets.each_with_object([]){|f_name,a| a.append([f_name, k, c.asc_select_merge(:target_tags, f_name).reject{|k,v| v.blank?}].compact)}
    # end

    # CRUD METHODS #############################################################
    # def add_field_and_merge(f_class, kind, type, f_name, tags, target_group, store)
    # 	f_obj = add_field(f_class, f_name.to_s, kind.to_s, tags)
    #   f_obj.config_assocs(target_group)
    # 	f_obj.add_and_assoc_targets(target_group, f_obj.fattrs.join('::')) if target_group
    # 	case_merge(store, f_obj, kind, type, f_name)
    # end
    #replace
    # def add_field_and_merge(f_class, kind, type, f_name, tags, target_group, store)
    #   f_obj = add_field(f_class, f_name.to_s, kind.to_s, tags)
    #   f_obj.config_assocs(target_group) if target_group
    #   f_obj.add_and_assoc_targets(target_group) if target_group
    #   case_merge(store, f_obj, kind, type, f_name)
    # end
    #replace
    # def add_field(f_class, f_name, kind, tags=nil)
    #   f = f_class.where(field_name: f_name, kind: kind).first_or_create
    #   f.update_tags(tags)
    #   f
    # end

    ############################################################################

    # def build_attrs(m)
    #   asc_select_merge(m).each_with_object({}) do |(attr,idx), h|
    #     h.merge!({attr => const_tree[idx]})
    #   end
    # end

    def build_attrs(m=:attrs)
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
