require 'active_support/concern'

module Crudable
  extend ActiveSupport::Concern

  def add_obj(obj)
    assoc_unless_included(obj)
  end

  def remove_obj(obj)
    remove_hmt(obj)
  end

  def replace_obj(new_obj, old_obj)
    remove_obj(old_obj)
    add_obj(new_obj)
  end

  # ##############################################################################

  def assoc_unless_included(target)
    self.target_collection(target) << target unless self.target_included?(target)
  end

  def target_collection(target)
    scoped_target_collection(target.class.name.underscore.pluralize)
  end

  def target_included?(target)
    self.target_collection(target).include?(target)
  end

  def scoped_target_collection(assoc)
    self.public_send(assoc)
  end

  def remove_hmt(obj, join_assoc=:item_groups)
    self.public_send(join_assoc).where(target_id: obj.id, target_type: obj.class.name).first.destroy
  end

  def find_target(target_type, target_id)
    to_class(target_type).find(target_id)
  end

  def to_class(type)
    type.classify.constantize
  end

  # ##############################################################################
  # def add_obj(obj)
  #   assoc_unless_included(obj)
  # end
  #

  #

  # ##############################################################################
  #
  # def update_field(item_params)
  #   field_args(item_params).each do |h|
  #     update_field_case(field_case_args(*h.values))
  #   end
  # end
  #
  # #CRUD: add ###################################################################
  # ##############################################################################
  # def add_param(k, t, f_name, v2)
  #   if input_attr?(t)
  #     @tags.merge!(add_tag_assoc(k, t, f_name, v2))
  #   else
  #     add_field(k, t, f_name, v2)
  #   end
  # end
  #
  # def add_field(k, t, f_name, f)
  #   assoc_unless_included(f)
  #   @tags.merge!(add_tag_assoc(k, t, f_name, f.id))
  # end
  #
  # def add_tag_assoc(k, t, f_name, v2)
  #   {tag_key(k, t, f_name) => v2}
  # end
  #
  # def tag_key(keys)
  #   keys.join('::')
  # end
  #
  # #CRUD: remove ################################################################
  # ##############################################################################
  # def remove_param(k, t, f_name, old_val)
  #   if input_attr?(t)
  #     remove_tag_assoc(k, t, f_name, old_val)
  #   else
  #     remove_field(k, t, f_name, old_val)
  #   end
  # end
  #
  # def remove_field(f, k, t, f_name)
  #   remove_field_set_fields(f.param_args(field_groups: f.g_hsh)) if params[:controller] == 'item_fields'
  #   remove_obj(f)
  #   remove_tag(f.id, k, t, f_name)
  # end
  #
  # def remove_tag_assoc(k, t, f_name, old_val)
  #   @tags.reject!{|key,val| tag_key(k, t, f_name) == key && val == old_val}
  # end
  #
  # def replace_param(k, t, f_name, new_val, old_val)
  #   remove_param(k, t, f_name, old_val)
  #   add_param(k, t, f_name, new_val)
  # end
  # ##############################################################################
  #
  # def field_case_args(k, t, f_name, f_val)
  #   {k: k, t: t, f_name: f_name, v: @input_params.dig(k,t,f_name), v2: param_val(t.classify, f_val)}
  # end
  #
  # def update_field_case(k:, t:, f_name:, v:, v2:)
  #   case update_case(item_val(t, v), v2)
  #     when :add; add_param(k, t, f_name, new_val(t, v2))
  #     when :remove; remove_param(k, t, f_name, v)
  #     when :replace; replace_param(k, t, f_name, new_val(t, v2), v)
  #   end
  # end
  # ##############################################################################
  # def param_val(t, v2)
  #   valid_field_val?(t, v2) ? v2.to_i : v2
  # end
  #
  # def item_val(t, v)
  #   valid_field_val?(t, v) ? v.id : v
  # end
  #
  # def valid_field_val?(t, val)
  #   !input_attr?(t) && !val.blank?
  # end
  # ##############################################################################
  # def update_case(v, v2)
  #   case
  #     when skip?(v, v2); :skip
  #     when remove?(v, v2); :remove
  #     when add?(v, v2); :add
  #     when replace?(v, v2); :replace
  #   end
  # end
  #
  # def skip?(v, v2)
  #   v.blank? && v2.blank? || v == v2
  # end
  #
  # def remove?(v, v2)
  #   !v.blank? && v2.blank?
  # end
  #
  # def add?(v, v2)
  #   v.blank? && !v2.blank?
  # end
  #
  # def replace?(v, v2)
  #   !v.blank? && !v2.blank?
  # end
  ##############################################################################
end
