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

  # ############################################################################

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

  # ############################################################################

  def find_target(target_type, target_id)
    to_class(target_type).find(target_id)
  end

  def to_class(type)
    type.classify.constantize
  end

end
