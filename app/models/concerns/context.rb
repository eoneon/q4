require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do

    #abbreviated subclass builder methods for readability ###############################
    #these could theoretically be added to FieldItem superclass and then just have non-applicable subclasses like Option just overwright with their own method
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

    #abbreviated builder methods for readability ####################################################################
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

    def klass_name
      slice_class(-1)
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
