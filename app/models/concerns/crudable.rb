require 'active_support/concern'

module Crudable
  extend ActiveSupport::Concern

  def add_obj(obj)
    assoc_unless_included(obj)
  end

  def remove_obj(obj)
    remove_hmt(obj: obj)
  end

  def replace_obj(old_obj, new_obj)
    remove_obj(old_obj)
    add_obj(new_obj)
  end

  def update_tags(tag_hsh)
    return if tag_hsh.blank? || tag_hsh.stringify_keys == self.tags
    self.tags = assign_or_merge(self.tags, tag_hsh.stringify_keys)
    self.save
  end

  def update_csv_tags(tag_hsh)
    return if tag_hsh.blank? || tag_hsh.stringify_keys == self.csv_tags
    self.csv_tags = assign_or_merge(self.csv_tags, tag_hsh.stringify_keys)
    self.save
  end

  def assign_or_merge(h, h2)
    h.nil? ? h2 : h.merge!(h2)
  end
  # ############################################################################

  ############################################################################
  def update_item(assoc_params, item_params)
  	return if assoc_params.detect {|target_name, param_val| update_item_target(target_name, public_send(target_name), param_val(target_name, param_val))}
  	assign_attributes(item_params)
  end

  def update_item_target(target_name, old_target, new_id)
    if update_context = update_case(target_id(old_target), new_id)
  		public_send("update_item_#{target_name}", update_context, target_name, old_target, new_id)
  	end
  end

  def update_item_product(update_context, target_name, old_target, new_id)
  	case update_context
      when :add; add_product(find_target(target_name, new_id))
  		when :remove; remove_product(old_target)
  		when :replace; replace_product(old_target, find_target(target_name, new_id))
  	end
  end

  def update_item_artist(update_context, target_name, old_target, new_id)
  	case update_context
  		when :add; add_obj(find_target(target_name, new_id))
  		when :remove; remove_obj(old_target)
  		when :replace; replace_obj(old_target, find_target(target_name, new_id))
  	end
  end

  ############################################################################
  ############################################################################
  def update_target_case(t, old_val, new_val)
    case update_case(item_val(t, old_val), param_val(t, new_val))
      when :add; add_obj(new_val(t, new_val))
      when :remove; remove_obj(old_val)
      when :replace; replace_obj(old_val, new_val(t, new_val))
    end
  end

  def update_case(old_val, new_val)
    case
      when skip?(old_val, new_val); :skip
      when remove?(old_val, new_val); :remove
      when add?(old_val, new_val); :add
      when replace?(old_val, new_val); :replace
    end
  end

  def skip?(old_val, new_val)
    old_val.blank? && new_val.blank? || old_val == new_val
  end

  def remove?(old_val, new_val)
    !old_val.blank? && new_val.blank?
  end

  def add?(old_val, new_val)
    old_val.blank? && !new_val.blank?
  end

  def replace?(old_val, new_val)
    !old_val.blank? && !new_val.blank?
  end

  # ############################################################################

  def assoc_unless_included(target)
    target_collection(target) << target unless target_included?(target)
  end

  def target_collection(target)
    scoped_target_collection(target.class.name.underscore.pluralize)
  end

  def target_included?(target)
    target_collection(target).include?(target)
  end

  def scoped_target_collection(assoc)
    public_send(assoc)
  end

  # ############################################################################

  def find_target(target_type, target_id)
    to_class(target_type).find(target_id)
  end

  def hsh_init(tags)
    tags ? tags : {}
  end

  # ############################################################################

  # def build_field_assocs
  #   all.select{|f| f.assocs && f.assocs.any?}.map {|f| assoc_fields(f)}
  # end
  #
  # def assoc_fields(f)
  #   f.assocs.transform_keys{|k| k.to_i}.sort_by{|k,v| k}.map{|assoc| build_assoc(f, *assoc[1].split('::'))}
  # end

  # def build_assoc(f, t, k, f_name)
  #   f.assoc_unless_included(f.to_class(t).where(kind: k, field_name: f_name).first_or_create)
  # end

  # def assoc_fields
  #   assocs.transform_keys{|k| k.to_i}.sort_by{|k,v| k}.map{|assoc| build_assoc(*assoc[1].split('::'))}
  # end
  #
  # def build_assoc(t, k, f_name)
  #   self.assoc_unless_included(to_class(t).where(kind: k, field_name: f_name).first_or_create)
  # end
end


# def remove_hmt(obj, join_assoc=:item_groups)
#   self.public_send(join_assoc).where(target_id: obj.id, target_type: obj.class.name).first.destroy
# end
