require 'active_support/concern'

module TypeCheck
  extend ActiveSupport::Concern

  # FieldItem is_a? based on :kind #############################################
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
    %w[sculpture_type numbering medium material signature certificate].include?(k)
  end

  # FieldItem is_a? based on :type #############################################
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

  def radio_button?(t)
    t.underscore == 'radio_button'
  end

  def tag_attr?(t)
    tag_attrs.include?(t)
  end

  def tag_attrs
    %w[number_field text_field text_area_field]
  end

  def product_category(product_type)
    [:flat_art?, :gartner_blade?, :sculpture_art?].each do |m|
      if p_category = public_send(m, product_type)
        return p_category
      end
    end
  end

  def flat_art?(product_type)
    'FlatArt' if !gartner_blade?(product_type) && !sculpture_art?(product_type)
  end

  def gartner_blade?(product_type)
    product_type if product_type == 'GartnerBlade'
  end

  def sculpture_art?(product_type)
    product_type if product_type == 'SculptureArt'
  end

  # ItemProduct is_a? based on input_group[:d_hsh] #############################
  def framed?(h)
    d_params?(h, 'tagline', 'mounting', 'Framed')
  end

  def embellished?(h)
    h['embellished']
  end

  def giclee?(h)
    d_params?(h, 'tagline', 'medium', 'Giclee')
  end

  def print?(h)
    d_params?(h, 'tagline', 'medium', 'Print')
  end

  def poster?(h)
    d_params?(h, 'tagline', 'medium', 'Poster')
  end

  def gallery_wrapped?(h)
    d_params?(h, 'tagline', 'material', 'Gallery')
  end

  def stretched?(h)
    d_params?(h, 'body', 'material', 'stretched')
  end

  def standard_paper?(h)
    d_params?(h, 'tagline', 'material', 'Paper') && !rice_paper?(h)
  end

  def rice_paper?(h)
    d_params?(h,'tagline', 'material', 'Rice')
  end

  def limited_edition?(h)
    h['edition_type']
  end

  def standard_numbering?(h)
    h['numbering'] && !from_an_edition?(h)
  end

  def from_an_edition?(h)
    d_params?(h, 'tagline', 'numbering', 'from')
  end

  def unsigned?(h)
    d_params?(h, 'tagline', 'signature', '(Unsigned)')
  end

  def signed?(h)
    h['signature'] && !unsigned?(h)
  end

  def danger_disclaimer(h)
    d_params?(h, 'tagline', 'disclaimer', '(Disclaimer)')
  end

  ##############################################################################
  def one_submedia?(h)
    h['leafing'] && !h['remarque'] || !h['leafing'] && h['remarque']
  end

  def two_submedia?(h)
    h['leafing'] && h['remarque']
  end

  def numbered_and_signed?(h)
    standard_numbering?(h) && signed?(h)
  end
  ##############################################################################

  def d_params?(h, context, *params)
    trans_args(params).all?{|args| h.keys.include?(args[0]) && h[args[0]][context].split(' ').include?(args[1])}
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

  def is_numeric?(s)
    !!Float(s) rescue false
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

# def tagline_keys
#   {'FlatArt'=> %w[artist title mounting embellishing category edition_type medium material dimension leafing remarque numbering signature certificate disclaimer]}
# end
