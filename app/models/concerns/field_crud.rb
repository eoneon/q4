require 'active_support/concern'

module FieldCrud
  extend ActiveSupport::Concern

  def update_field(param_set, input_params)
    param_set.each do |f_hsh|
      k, t, f_name, param_val = f_hsh.values
      item_val = input_params.dig(k,t,f_name)
      context = update_case(item_val(t, item_val), param_val(t, param_val))
      update_field_case(k: k, t: t, f_name: f_name, v: item_val, v2: param_val, context: context, input_params: input_params) unless context == :skip
      break if update_complete?(context)
    end
  end

  def update_field_case(k:, t:, f_name:, v:, v2:, context:, input_params:)
    case context
      when :add; add_param(k, t, f_name, new_val(t, v2))
      when :remove; remove_param(k, t, f_name, v, input_params)
      when :replace; replace_param(k, t, f_name, new_val(t, v2), v, input_params)
    end
  end

  def update_complete?(context)
    context != :skip
  end

  # update context-routing methods #############################################
  # primary method #############################################################

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

  # add methods ################################################################
  # standard add ###############################################################
  def add_param(k, t, f_name, v2)
    if tag_attr?(t)
      add_tag_assoc(k, t, f_name, v2)
    else
      add_field(k, t, f_name, v2)
    end
  end

  def add_field(k, t, f_name, f)
    assoc_unless_included(f)
    add_tag_assoc(k, t, f_name, f.id)
    add_default_field_set_fields(f,t)
  end

  def add_tag_assoc(k, t, f_name, v2)
    self.tags.merge!(tag_assoc(k, t, f_name, v2))
    self.save
  end

  def add_default_field_set_fields(f,t)
    if field_set?(t)
      f.select_fields.map{|sf| add_default(sf.kind.underscore, sf.type, sf.field_name.underscore, sf)}
    end
  end

  # remove methods #############################################################
  def remove_param(k, t, f_name, old_val, input_params)
    if tag_attr?(t)
      remove_tag_assoc(k, t, f_name, old_val)
    else
      remove_field_set_fields(old_val.f_args(old_val.g_hsh), input_params) if field_set?(t)
      remove_field(k, t, f_name, old_val)
    end
  end

  def remove_field(k, t, f_name, f)
    remove_tag_assoc(k, t, f_name, tag_id(f))
    remove_hmt(f)
  end

  def remove_field_set_fields(field_args, input_params)
    field_args.each do |f_hsh|
      k, t, f_name, f_val = h_vals(f_hsh, :k, :t, :f_name, :f_val)
      if select_field?(t)
        remove_field_set_fields(f_val.f_args(f_val.g_hsh), input_params)
      elsif old_val = input_params.dig(k,t,f_name)
        remove_param(k, t, f_name, old_val, input_params)
      end
    end
  end

  def remove_fieldables
    fieldables.map{|f| remove_hmt(f)}
    self.tags = nil
  end

  # product_fields remove ######################################################
  def remove_product_fields(input_params)
    return if self.tags.nil?
    f_args(input_params).each do |f_hsh|
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

  def remove_tag_assoc(k, t, f_name, old_val)
    self.tags.reject!{|key,val| tag_key(k, t, f_name) == key && val == old_val}
    self.save
  end

  # replace methods ############################################################
  def replace_param(k, t, f_name, new_val, old_val, input_params)
    remove_param(k, t, f_name, old_val, input_params)
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
    first_fieldable(f_val) if default_option_kind?(k)
  end

  def default_field_set(f_val)
    first_fieldable(f_val)
  end

  # utility methods for default add ############################################
  def valid_default_option?(k,t)
    select_field?(t) && default_option_kind?(k)
  end

  def valid_default_field_set?(k,t)
    dimension?(k) && select_menu?(t) || numbering?(k) && select_menu?(t)
  end

  def compound_classify(name)
    name.split(' ').join('_').classify
  end

  def first_fieldable(f)
    f.fieldables.first
  end

  # basic utility methods ######################################################
  def tag_assoc(k, t, f_name, v2)
    {tag_key(k, t, f_name) => v2}
  end

  def tag_key(*keys)
    keys.join('::')
  end

  def tag_id(f)
    f.id.to_s
  end
end


# def update_actions(k:, t:, f_name:, v:, v2:, context:, input_params:)
#   remove_field_set_fields(v.f_args(v.g_hsh), input_params) if remove_field_set?(t, context)
#   update_field_case(k: k, t: t, f_name: f_name, v: v, v2: v2, context: context) unless context == :skip
# end
#
# def remove_field_set?(t, context)
#   field_set?(t) && [:remove, :replace].include?(context)
# end

# def update_field_case(k:, t:, f_name:, v:, v2:, context:)
#   case context
#     when :add; add_param(k, t, f_name, new_val(t, v2))
#     when :remove; remove_param(k, t, f_name, v)
#     when :replace; replace_param(k, t, f_name, new_val(t, v2), v)
#   end
# end

# def add_field_set?(t, context)
#   field_set?(t) && [:add, :replace].include?(context)
# end

# def detect_matching_field_names(f_obj)
#   f_obj.fieldables.detect{|f| classify_name_match?(f.field_name, f_obj.field_name)}
# end

# def classify_name_match?(*names)
#   names.map{|n| compound_classify(n)}.uniq.one?
# end
