require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do
    #FlatMaterialType.build_type_group
    #auto-pop methods: not sure if we need to relocate at some point ###########
    def build_type_group
      self.subclasses.each do |klass|
        build_product_item(klass)
      end
    end

    def build_product_item(klass)
      product_item = base_type_class.where(item_name: decamelize(klass.slice_class(-1))).first_or_create
      build_and_assoc_set(product_item, klass) if method_exists?(klass, :set)
    end

    def build_and_assoc_set(product_item, klass)
      if klass.set.first.class == String
        assoc_unless_included(product_item, build_select_field(klass))
      else
        build_product_item_set(product_item, klass)
      end
      product_item
    end

    def build_product_item_set(product_item, klass)
      klass.set.each do |target_class|
        target = build_product_item(target_class)
        assoc_unless_included(product_item, target)
      end
      product_item
    end

    def assoc_unless_included(origin, target)
      origin.target_collection(target) << target unless origin.target_included?(target)
    end

    def build_select_field(klass)
      select_field = SelectField.where(field_name: "#{decamelize(klass.slice_class(-1))}-options").first_or_create
      build_options(select_field, klass.set)
    end

    def build_options(select_field, opt_set)
      opt_set.each do |opt_name|
        opt = Option.where(field_name: opt_name).first_or_create
        assoc_unless_included(select_field, opt)
      end
      select_field
    end

    # parse scope chain relative to self #######################################
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
