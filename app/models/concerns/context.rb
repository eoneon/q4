require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do

    def select_field_group(field_name, options)
      SelectField.builder(f={field_name: field_name, options: options})
    end

    def build_name(name_set)
      name_set.uniq.reject {|i| i.blank?}.join(" ")
    end

    # parse scope chain relative to self #######################################
    def field_class_name
      decamelize(klass_name)
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

    def decamelize(camel_word, *delim)
      delim = delim.empty? ? ' ' : delim.first
      name_set = camel_word.to_s.underscore.split('_')
      name_set.join(delim)
    end

  end
end
