require 'active_support/concern'

module TypeCheck
  extend ActiveSupport::Concern

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

  def product_class?
    self.class.name == 'Product'
  end

  def type?(obj)
    obj.class.method_defined?(:type)
  end
end
