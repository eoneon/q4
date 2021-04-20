require 'active_support/concern'

module TypeCheck
  extend ActiveSupport::Concern

  # check kind #################################################################
  def dimension?(k)
    k == 'dimension'
  end

  def numbering?(k)
    k == 'numbering'
  end

  def medium?(k)
    k == 'medium'
  end

  def material?(k)
    k == 'material'
  end

  def default_option_kind?(k)
    %w[edition medium material signature certificate].include?(k)
  end

  # check type #################################################################
  def field_set?(t)
    t.underscore == 'field_set'
  end

  def select_field?(t)
    t.underscore == 'select_field'
  end

  def select_menu?(t)
    t.underscore == 'select_menu'
  end

  def option?(t)
    t.underscore == 'option'
  end

  def tag_attr?(t)
    tag_attrs.include?(t)
  end

  def tag_attrs
    %w[number_field text_field text_area_field]
  end

  # check association ##########################################################
  def f_assoc(t)
    tag_attr?(t) || option?(t) ? t : to_class(t).assoc_names[0].singularize
  end

  # check class ################################################################
  def product_class?
    self.class.name == 'Product'
  end

  def to_class(type)
    type.to_s.classify.constantize
  end

  class_methods do
    def assoc_names
      self.reflect_on_all_associations(:has_many).map{|assoc| assoc.name.to_s}.reject {|i| i == 'item_groups'}
    end

    def field_set_assoc?
      self.assoc_names[0] == 'field_sets'
    end

    def option_assoc?
      self.assoc_names[0] == 'options'
    end

    def no_assoc?
      self.assoc_names.none?
    end
  end
end

# check STI ##################################################################
# def type?(obj)
#   obj.class.method_defined?(:type)
# end
