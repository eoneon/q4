require 'active_support/concern'

module FieldCrud
  extend ActiveSupport::Concern

  # update context-routing methods #############################################
  # primary method #############################################################
  def update_field(param_set)
    param_set.each do |h|
      update_field_case(field_case_args(*h.values))
    end
  end

  def update_field_case(k:, t:, f_name:, v:, v2:)
    case update_case(item_val(t, v), v2)
      when :add; add_param(k, t, f_name, new_val(t, v2))
      when :remove; remove_param(k, t, f_name, v)
      when :replace; replace_param(k, t, f_name, new_val(t, v2), v)
    end
  end

  def field_case_args(k, t, f_name, f_val)
    {k: k, t: t, f_name: f_name, v: input_params.dig(k,t,f_name), v2: param_val(t.classify, f_val)}
  end

  def param_val(t, v2)
    valid_field_val?(t, v2) ? v2.to_i : v2
  end

  def item_val(t, v)
    valid_field_val?(t, v) ? v.id : v
  end

  def new_val(t, v2)
    valid_field_val?(t, v2) ? find_target(t, v2) : v2
  end

  def valid_field_val?(t, val)
    !tag_attr?(t) && !val.blank?
  end

  # update_case ################################################################
  ##############################################################################
  def update_case(v, v2)
    case
      when skip?(v, v2); :skip
      when remove?(v, v2); :remove
      when add?(v, v2); :add
      when replace?(v, v2); :replace
    end
  end

  def skip?(v, v2)
    v.blank? && v2.blank? || v == v2
  end

  def remove?(v, v2)
    !v.blank? && v2.blank?
  end

  def add?(v, v2)
    v.blank? && !v2.blank?
  end

  def replace?(v, v2)
    !v.blank? && !v2.blank?
  end

  # add methods ################################################################
  # standard add ###############################################################
  def add_param(k, t, f_name, v2)
    if tag_attr?(t)
      self.tags.merge!(add_tag_assoc(k, t, f_name, v2))
    else
      add_field(k, t, f_name, v2)
    end
  end

  def add_field(k, t, f_name, f)
    assoc_unless_included(f)
    self.tags.merge!(add_tag_assoc(k, t, f_name, f.id))
  end

  def add_tag_assoc(k, t, f_name, v2)
    {tag_key(k, t, f_name) => v2}
  end

  # remove methods #############################################################
  # standard remove ############################################################
  def remove_param(k, t, f_name, old_val)
    if tag_attr?(t)
      remove_tag_assoc(k, t, f_name, old_val)
    else
      remove_field(k, t, f_name, old_val)
    end
  end

  def remove_field(k, t, f_name, f)
    remove_field_set_fields(f.field_args(f.g_hsh)) if field_set?(t)#if params[:controller] == 'item_fields' && field_set?(t)
    remove_hmt(f)
    remove_tag_assoc(k, t, f_name, tag_id(f))
  end

  def remove_field_set_fields(field_args)
    field_args.each do |f_hsh|
      k, t, f_name, f_val = h_vals(f_hsh, :k, :t, :f_name, :f_val)
      if old_val = input_params.dig(k,t,f_name)
        remove_param(k, t, f_name, old_val)
      end
    end
  end

  # product_fields remove ######################################################
  def remove_product_fields
    return if self.tags.nil?
    field_args(input_params).each do |f_hsh|
      remove_product_field_param(*h_vals(f_hsh, :k, :t, :f_name, :f_val))
    end
  end

  def remove_product_field_param(k, t, f_name, f_val)
    if tag_attr?(t)
      remove_tag_assoc(k, t, f_name, f_val)
    else
      remove_tag_assoc(k, t, f_name, tag_id(f_val))
      remove_hmt(f_val)
    end
  end
  ##############################################################################

  def remove_tag_assoc(k, t, f_name, old_val)
    self.tags.reject!{|key,val| tag_key(k, t, f_name) == key && val == old_val}
  end

  # replace methods ############################################################
  def replace_param(k, t, f_name, new_val, old_val)
    remove_param(k, t, f_name, old_val)
    add_param(k, t, f_name, new_val)
  end

  # default add ################################################################

  def add_default_fields(field_args)
    field_args.each do |f_hsh|
      add_default(*h_vals(f_hsh, :k, :t, :f_name, :f_val))
    end
  end

  def add_default(k, t, f_name, f_val)
    if f = default_field(k, t, f_val)
      add_field(k, f.type.underscore, f_name, f)
    end
  end

  def default_field(k, t, f_val)
    if valid_default_option?(k,t)
      default_option(k, f_val)
    elsif valid_default_field_set?(k,t)
      default_field_set(f_val)
    end
  end

  def default_option(k, f_val)
    if medium?(k)
      detect_matching_field_names(f_val)
    elsif default_option_kind?(k)
      first_fieldable(f_val)
    end
  end

  def default_field_set(f_val)
    first_fieldable(f_val)
  end

  # utility methods for default add ############################################
  def valid_default_option?(k,t)
    select_field?(t) && default_option_kind?(k)
  end

  def valid_default_field_set?(k,t)
    dimension?(k) && select_menu?(t)
  end

  def detect_matching_field_names(f_obj)
    f_obj.fieldables.detect{|f| classify_name_match?(f.field_name, f_obj.field_name)}
  end

  def classify_name_match?(*names)
    names.map{|n| compound_classify(n)}.uniq.one?
  end

  def compound_classify(name)
    name.split(' ').join('_').classify
  end

  def first_fieldable(f)
    f.fieldables.first
  end

  # basic utility methods ######################################################

  def tag_key(*keys)
    keys.join('::')
  end

  def tag_id(f)
    f.id.to_s
  end

  # def hsh_init(h)
  #   h ? h : {}
  # end
end
