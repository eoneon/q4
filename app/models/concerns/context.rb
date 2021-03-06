require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do

    #abbreviated subclass builder methods for readability ###############################
    def product(product_name, options, tags=nil)
      Product.builder({product_name: product_name, options: options, tags: tags})
    end

    # def standard_product(field_name, options, tags=nil)
    #   StandardProduct.builder(f={product_name: field_name, options: options, tags: tags})
    # end

    def select_menu(field_name, kind, options, tags=nil)
      SelectMenu.builder(f={field_name: field_name, kind: kind, options: options, tags: tags})
    end

    def field_set(field_name, kind, options, tags=nil)
      FieldSet.builder(f={field_name: field_name, kind: kind, options: options, tags: tags})
    end

    def select_field(field_name, kind, options, tags=nil)
      SelectField.builder(f={field_name: field_name, kind: kind, options: options, tags: tags})
    end

    def radio_button(field_name, kind, tags=nil)
      RadioButton.builder(f={field_name: field_name, kind: kind, tags: tags})
    end

    def number_field(field_name, kind, tags=nil)
      NumberField.builder(f={field_name: field_name, kind: kind, tags: tags})
    end

    def text_field(field_name, kind, tags=nil)
      TextField.builder(f={field_name: field_name, kind: kind, tags: tags})
    end

    def text_area(field_name, kind, tags=nil)
      TextAreaField.builder(f={field_name: field_name, kind: kind, tags: tags})
    end

    #builder methods for lib classes  ##########################################
    #in use?
    def builder
      self.subclasses.map {|klass| klass.builder}
    end

    # parse scope chain relative to self #######################################
    def field_name
      decamelize(klass_name)
    end

    def field_kind
      slice_class(0).underscore
    end
    #redundant?
    def tags_hsh(kind_idx, sub_kind_idx)
      set = self.to_s.split('::').map{|klass| klass.underscore}
      h={kind: set[kind_idx], sub_kind: set[sub_kind_idx]}
    end

    # parse scope chain relative to self #######################################
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

    #insert with map prepend/append ############################################
    def cascade_merge(klass, set, opt_hsh={})
      opt_hsh = opt_hsh.merge(klass.opt_hsh) if method_exists?(klass, :opt_hsh)
      return set.append(opt_hsh) if !klass.subclasses.any?
      klass.subclasses.each do |target_class|
        cascade_merge(target_class, set, opt_hsh.merge(target_class.opt_hsh))
      end
    end

    def option_set_build(options:, prepend_set: [], append_set: [], insert_set: [])
      options = prepend_build(options, prepend_set) if prepend_set.any?
      options = append_build(options, append_set) if append_set.any?
      options = insert_build(options, insert_set) if insert_set.any?
      options.flatten
    end

    def prepend_build(options, prepend_set)
      prepend_set.reverse.map {|opt| options.prepend(opt)}.flatten
      options
    end

    def append_build(options, append_set)
      append_set.map {|opt| options.append(opt)}.flatten if append_set.any?
      options
    end

    def insert_build(options, insert_set)
      insert_set.map {|a| options.insert(a[0], a[1])}.flatten if insert_set.any?
      options
    end

    def arg_as_arr(arg)
      arg.class == Array ? arg : [arg]
    end

    def build_options(options)
      options.map{|klass| klass.builder}.flatten
    end

    def kv_assign(tags, kv_sets)
      kv_sets.map{|kv| tags[kv[0]] = kv[1]}
      tags
    end

    # utility methods -> not currently using ###################################
    def flat_class_set(origin_class, set=[])
      origin_class.subclasses.each do |klass|
        set << subclass_dig(klass)
      end
      set.flatten
    end

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

    def cap_words(words)
      words.split(' ').map{|word| word.capitalize}.join(' ')
    end

  end
end
