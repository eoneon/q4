require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do
    # def product(type, product_name, options, tags=nil)
    #   type.constantize.builder(p={product_name: product_name, options: options, tags: tags})
    # end

    #abbreviated subclass builder methods for readability ###############################
    def standard_product(field_name, options, tags=nil)
      StandardProduct.builder(f={field_name: field_name, options: options, tags: tags})
    end

    def select_menu(field_name, options, tags=nil)
      SelectMenu.builder(f={field_name: field_name, options: options, tags: tags})
    end

    def field_set(field_name, options, tags=nil)
      FieldSet.builder(f={field_name: field_name, options: options, tags: tags})
    end

    def select_field(field_name, options, tags=nil)
      SelectField.builder(f={field_name: field_name, options: options, tags: tags})
    end

    def radio_button(field_name, tags=nil)
      RadioButton.builder(f={field_name: field_name, tags: tags})
    end

    def number_field(field_name, tags=nil)
      NumberField.builder(f={field_name: field_name, tags: tags})
    end

    def text_field(field_name, tags=nil)
      TextField.builder(f={field_name: field_name, tags: tags})
    end

    def text_area_field(field_name, tags=nil)
      TextField.builder(f={field_name: field_name, tags: tags})
    end

    #abbreviated builder methods for readability ###############################
    def builder
      self.subclasses.map {|klass| klass.builder}
    end

    def build_name(name_set)
      name_set.uniq.reject {|i| i.blank?}.join(" ")
    end

    # parse scope chain relative to self #######################################
    def field_class_name
      decamelize(klass_name)
    end

    def search_hsh
      h={kind: slice_class(-2).underscore, sub_kind: klass_name.underscore}
    end

    def tags_hsh(kind_idx, sub_kind_idx)
      set = self.to_s.split('::').map{|klass| klass.underscore}
      h={kind: set[kind_idx], sub_kind: set[sub_kind_idx]}
    end

    def klass_name
      slice_class(-1)
    end

    def split_class
      self.to_s.split('::')
    end

    def slice_class(i=nil)
      i.nil? ? self.to_s : self.to_s.split('::')[i]
    end

    def base_type
      slice_class(0).split("Type").first
    end

    def base_type_class
      base_type.constantize
    end

    def flat_class_set(origin_class, set=[])
      origin_class.subclasses.each do |klass|
        set << subclass_dig(klass)
      end
      set.flatten
    end

    #insert with map prepend/append ############################################
    def option_set_build(options:, prepend_set: [], append_set: [], insert_set: [])
      options = insert_build(options, insert_set) if insert_set.any?
      options = prepend_build(options, prepend_set)
      options = append_build(options, append_set)
      options.flatten
    end

    def insert_build(set, insert_set)
      insert_set.map {|a| set.insert(a[0], a[1])}.flatten if insert_set.any?
    end

    def prepend_build(set, prepend_set)
      prepend_set = arg_as_arr(prepend_set)
      prepend_set.reverse.map {|v| set.prepend(v)}.flatten if prepend_set.any?
      set
    end

    def append_build(set, append_set)
      append_set = arg_as_arr(append_set)
      append_set.map {|v| set.append(v)}.flatten if append_set.any?
      set
    end

    def arg_as_arr(arg)
      arg.class == Array ? arg : [arg]
    end

    # utility methods ##########################################################
    def subclass_dig(klass)
      if klass.subclasses.any?
        klass.subclasses.map{|sklass| subclass_dig(sklass)}
      else
        klass
      end
    end

    # utility methods ##########################################################
    def method_exists?(klass, method)
      klass.methods(false).include?(method)
    end

    # array parsing methods ####################################################
    def include_any?(arr_x, arr_y)
      arr_x.any? {|x| arr_y.include?(x)}
    end

    def include_all?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.include?(x)}
    end

    def exclude_all?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.exclude?(x)}
    end

    def include_none?(arr_x, arr_y)
      arr_x.all? {|x| arr_y.exclude?(x)}
    end

    def include_pat?(str, pat)
      str.index(/#{pat}/)
    end

    # text formatting methods ##################################################
    def decamelize(camel_word, *delim)
      delim = delim.empty? ? ' ' : delim.first
      name_set = camel_word.to_s.underscore.split('_')
      name_set.join(delim)
    end

    def arr_to_text(arr)
      if arr.length == 2
        arr.join(" & ")
      elsif arr.length > 2
        [arr[0..-3].join(", "), arr[-2, 2].join(" & ")].join(", ")
      else
        arr[0]
      end
    end

    def format_vowel(vowel, word)
      %w[a e i o u].include?(word.first.downcase) && word.split('-').first != 'one' ? 'an' : 'a'
    end

  end
end
