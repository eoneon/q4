require 'active_support/concern'

module Context
  extend ActiveSupport::Concern

  class_methods do

    def build_type_group
      self.subclasses.each do |klass|
        build_product_item(klass)
      end
    end

    def build_product_item(klass)
      product_item = ProductItem.where(type: base_type, item_name: decamelize(klass.slice_class(-1))).first_or_create
      if method_exists?(klass, :set)
        build_and_assoc_set(product_item, klass)
      end
    end

    # def build_and_assoc_set(product_item, klass)
    #   # target = klass.set.first == String ? build_select_field(klass) : build_product_items(klass)
    #   # assoc_unless_included(product_item, target)
    #   if klass.set.first == String
    #     assoc_unless_included(product_item, build_select_field(klass))
    #   else
    #     assoc_unless_included(product_item, build_product_items(klass))
    #   end
    # end

    def build_and_assoc_set(product_item, klass)
      if klass.set.first.class == String
        assoc_unless_included(product_item, build_select_field(klass))
        # select_field = build_select_field(klass)
        # assoc_unless_included(product_item, select_field)
      end
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

    def build_product_items(klass)
      build_product_item(klass)
    end

    def assoc_unless_included(origin, target)
      origin.target_collection(target) << target unless origin.target_included?(target)
    end

    # parse scope chain relative to self #########################################
    def klass_name
      slice_class(-1)
    end

    def slice_class(i=nil)
      i.nil? ? self.to_s : self.to_s.split('::')[i]
    end

    def base_type
      slice_class(0).split("Type").first
    end

    # def format_constant(konstant)
    #   konstant.to_s.split(' ').map {|word| word.underscore.split('_').map {|split_word| split_word.capitalize}}.flatten.join('')
    # end

    # utility methods ############################################################
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

# scope methods ##############################################################
# def scope_context(*konstant_objs)
#   set=[]
#   konstant_objs.each do |konstant_obj|
#     if konstant_obj.to_s.index('::')
#       konstant_obj.to_s.split('::').map {|konstant| set << konstant}
#     else
#       set << format_constant(konstant_obj)
#     end
#   end
#   set.join('::').constantize
# end
#
