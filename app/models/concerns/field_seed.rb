require 'active_support/concern'

module FieldSeed
  extend ActiveSupport::Concern

  class_methods do

    # CRUD #####################################################################
    ############################################################################
    def add_field_group(f_class, member_class, f_type, f_kind, f_name, store, tags=nil)
      f = add_field(f_class, f_name, f_kind, tags)
      f.add_and_assoc_targets(member_class.targets) if member_class.method_exists?(:targets) #unless f_type == 'RadioButton'
      merge_field(Item.dig_set(k: f_name.to_sym, v: f, dig_keys: [f_kind.to_sym, f_type.to_sym]), store)
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
    #asc_build_detected_tags_and_merge
    def build_tags(args, *methods)
      asc_detect_classes_with_methods(methods).each_with_object({}) do |(m,c), tags|
        tags.merge!({m => c.public_send(m, args)})
      end
    end

    #asc_select_hash_method_and_merge
    def build_attrs(meth)
      merge_asc_selected_hash_methods(meth).each_with_object({}) do |(attr,idx), h|
        h.merge!({attr => const_tree[idx]})
      end
    end
    ############################################################################

    def merge_enum(desc_meth, asc_meth, *dig_keys)
      desc_select_asc_detect_and_call(desc_meth, asc_meth).each_with_object({}) do |(c,set),h|
        #c.public_send(asc_meth).map {|k| (h.has_key?(k) ? h[k].append(c.const) : h[k] = [c.const])}
        set.map {|k| case_merge(h,k,[c], *dig_keys)}
      end
    end

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

    def assign_or_merge(h, h2)
      h.nil? ? h2 : h.merge(h2)
    end

    def merge_field(dig_set, store)
      Item.param_merge(params: store, dig_set: dig_set)
    end
    ##############################################################################
    ##############################################################################

    def dig_and_assoc(f, targets, store)
      dig_fields(targets, store).map{|field| f.assoc_unless_included(field)}
    end

    def build_target_group(f_names, f_type, f_kind)
      f_names.map{|f_name| [f_type, f_kind, f_name]}
    end

    ##############################################################################
    #STRING methods
    ##############################################################################

    def class_to_cap(class_word, skip_list=[])
      class_word.underscore.split('_').map{|word| cap_word(word, skip_list)}.join(' ')
    end

    def cap_word(word, skip_list)
      skip_list.include?(word) ? word : word.capitalize
    end

    def edit_name(name, edit_list)
      name = edit_list.each_with_object(name) do |word_set|
        name.sub!(word_set[0], word_set[1])
      end
    end

    def edit_list
      [['Standard',''], ['Reproduction',''], ['On Paper', ''], ['One Of A Kind', 'One-of-a-Kind'], ['Of One', ' 1/1']]
    end

    def format_name(name)
      name.split(' ').map(&:strip).join(' ')
    end

    def indefinite_article(noun)
      %w[a e i o u].include?(noun.first.downcase) && noun.split('-').first != 'one' || noun == 'HC' ? 'an' : 'a'
    end
  end
end


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
