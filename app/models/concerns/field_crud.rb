require 'active_support/concern'

module FieldCrud
  extend ActiveSupport::Concern

  ##############################################################################
  #new
  def update_field(dig_keys, param_hsh)
  	update_field_case(param_val(dig_keys[2], param_hsh[:update_context]), param_val(dig_keys[2], param_hsh.dig(*dig_keys)), param_hsh[:item], (self.tags || {}), *dig_keys[1..-1])
  	self.tags = tags
  	self.save!
  end

  #new
  def update_field_case(pre_val, new_val, param_hsh, tags, k, t, f_name)
  	case
  		when add?(pre_val, new_val); add_param(k, t, f_name, new_val, tags)
  		when remove?(pre_val, new_val); remove_param(k, t, f_name, pre_val, param_hsh, tags)
  		when replace?(pre_val, new_val); replace_param(k, t, f_name, new_val, pre_val, param_hsh, tags)
  	end
  end

  #test
  # def update_field_case_test(pre_val, new_val, param_hsh, tags, k, t, f_name)
  # 	case
  # 		when add?(pre_val, new_val); puts ":add=> #{k}, #{t}, #{f_name}, #{new_val}"
  # 		when remove?(pre_val, new_val); puts ":remove=> #{k}, #{t}, #{f_name}, #{pre_val}, #{param_hsh}, #{tags}"
  # 		when replace?(pre_val, new_val); puts ":replace=> #{k}, #{t}, #{f_name}, #{pre_val}, #{new_val}, #{param_hsh}, #{tags}"
  # 	end
  # end

  #OG V: START #############################################################################
  # def update_field(param_set, input_params)
  #   param_set.each do |f_hsh|
  #     k, t, f_name, param_val = f_hsh.values
  #     item_val = input_params.dig(k,t,f_name)
  #     context = update_case(item_val(t, item_val), param_val(t, param_val))
  #     update_field_case(k: k, t: t, f_name: f_name, v: item_val, v2: param_val, context: context, input_params: input_params) unless context == :skip
  #     break if update_complete?(context)
  #   end
  # end
  # #OG V
  # def update_field_case(k:, t:, f_name:, v:, v2:, context:, input_params:)
  #   case context
  #     when :add; add_param(k, t, f_name, new_val(t, v2))
  #     when :remove; remove_param(k, t, f_name, v, input_params)
  #     when :replace; replace_param(k, t, f_name, new_val(t, v2), v, input_params)
  #   end
  # end

  def update_complete?(context)
    context != :skip
  end
  #END #OG V #############################################################################

  # update context-routing methods #############################################
  # primary method #############################################################

  def param_val(t, v2)
    valid_field_val?(t, v2) ? v2.to_i : v2
  end

  def item_val(t, v)
    valid_field_val?(t, v) ? v.id : v
  end

  def new_val(t, v2)
    valid_field_val?(t, v2) ? find_target(t, v2.to_i) : v2
  end

  def valid_field_val?(t, val)
    !tag_attr?(t) && !val.blank?
  end

  def config_item_params
  	tags.each_with_object({}) {|(input_key,v), ig_hsh| ig_hsh[input_key] = param_val(input_key.split('::')[1], v)}
  end

  # add methods ################################################################
  def add_param(k, t, f_name, new_val, tags)
  	if tag_attr?(t)
  		add_tag_assoc(k, t, f_name, new_val, tags)
  	else
  		add_field(k, t, f_name, new_val, tags)
  	end
  end

  def add_tag_assoc(k, t, f_name, new_val, tags)
  	tags.merge!(tag_assoc(k, t, f_name, new_val))
  end

  def add_field(k, t, f_name, new_val, tags)
  	f = find_target(t, new_val)
  	add_target_and_tag_assoc(f.kind.underscore, t, f_name, f, tags)
    f.fieldables.map{|f| add_default(f.kind.underscore, f.type.underscore, f.field_name.underscore, f, tags)}
  	#add_default_field_options(f.select_fields, tags) if field_set?(t)
  end

  def add_target_and_tag_assoc(k, t, f_name, f, tags)
  	assoc_unless_included(f)
  	add_tag_assoc(k, t, f_name, f.id, tags)
  end

  # def add_default_field_options(select_fields, tags)
  # 	select_fields.map{|f| (f.kind.underscore, f.type.underscore, f.field_name.underscore, f, tags)}
  # end

  def add_default(k, t, f_name, f_val, tags)
  	if f = default_field(k, t, f_val)
  		add_target_and_tag_assoc(f.kind.underscore, t, f_name, f, tags)
  	end
  end

  # OG V standard add ###############################################################
  # def add_param(k, t, f_name, v2)
  #   if tag_attr?(t)
  #     add_tag_assoc(k, t, f_name, v2)
  #   else
  #     add_field(k, t, f_name, v2)
  #   end
  # end
  #
  # def add_field(k, t, f_name, f)
  #   assoc_unless_included(f)
  #   add_tag_assoc(k, t, f_name, f.id)
  #   add_default_field_set_fields(f,t)
  # end
  #
  # def add_tag_assoc(k, t, f_name, v2)
  #   self.tags.merge!(tag_assoc(k, t, f_name, v2))
  #   self.save
  # end
  #
  # def add_default_field_set_fields(f,t)
  #   if field_set?(t)
  #     f.select_fields.map{|sf| add_default(sf.kind.underscore, sf.type, sf.field_name.underscore, sf)}
  #   end
  # end
  # End OG V ###############################################################

  # remove methods #############################################################
  def remove_param(k, t, f_name, old_val, param_hsh, tags)
  	if tag_attr?(t)
  		remove_tag_assoc(k, t, f_name, tags)
    else
  		remove_field(k, t, f_name, old_val, tags)
      remove_field_set_params(k, param_hsh, tags) if field_set?(t)
  	end
  end

  def remove_field(k, t, f_name, old_val, tags)
  	remove_tag_assoc(k, t, f_name, tags)
  	#remove_hmt(old_val, t.classify)
    remove_hmt(target_id: old_val, target_type: t.classify)
  end

  def remove_tag_assoc(k, t, f_name, tags)
  	tags.delete(tag_key(k, t, f_name))
  end

  def remove_field_set_params(k, param_hsh, tags)
  	param_hsh[k].reject{|t, f_params| field_set?(t)}.each do |t, f_params|
  		f_params.reject{|f_name, f_val| f_val.blank?}.each do |f_name, f_val|
  			remove_param(k, t, f_name, param_val(t, f_val), param_hsh, tags)
  		end
  	end
  end

  def remove_hmt(obj:nil, target_id:nil, target_type:nil, join_assoc: :item_groups)
  	target_id, target_type = obj ? [obj.id, obj.class.name] : [target_id, target_type]
  	self.public_send(join_assoc).where(target_id: target_id, target_type: target_type).first.destroy
  end

  # def remove_hmt(target_id, target_type, join_assoc=:item_groups)
  # 	self.public_send(join_assoc).where(target_id: target_id, target_type: target_type).first.destroy
  # end

  def replace_param(k, t, f_name, new_val, old_val, param_hsh, tags)
  	remove_param(k, t, f_name, old_val, param_hsh, tags)
  	add_param(k, t, f_name, new_val, tags)
  end
  # remove methods #############################################################

  # OG V remove methods #############################################################
  # def remove_param(k, t, f_name, old_val, input_params)
  #   if tag_attr?(t)
  #     remove_tag_assoc(k, t, f_name, old_val)
  #   else
  #     remove_field_set_fields(old_val.f_args(old_val.g_hsh), input_params) if field_set?(t)
  #     remove_field(k, t, f_name, old_val)
  #   end
  # end
  #
  # def remove_field(k, t, f_name, f)
  #   remove_tag_assoc(k, t, f_name, tag_id(f))
  #   remove_hmt(f)
  # end
  #
  # def remove_field_set_fields(field_args, input_params)
  #   field_args.each do |f_hsh|
  #     k, t, f_name, f_val = h_vals(f_hsh, :k, :t, :f_name, :f_val)
  #     if select_field?(t)
  #       remove_field_set_fields(f_val.f_args(f_val.g_hsh), input_params)
  #     elsif old_val = input_params.dig(k,t,f_name)
  #       remove_param(k, t, f_name, old_val, input_params)
  #     end
  #   end
  # end
  #
  # def remove_tag_assoc(k, t, f_name, old_val)
  #   self.tags.reject!{|key,val| tag_key(k, t, f_name) == key && val == old_val}
  #   self.save
  # end
  # END OG V remove methods #############################################################

  def remove_fieldables
    fieldables.map{|f| remove_hmt(target_id: f.id, target_type: f.type)} #f.id, f.type
    self.tags = nil
    self.csv_tags = nil
    self.save!
  end

  # def remove_csv_tags(csv_tags)
  #   keys = csv_tags['category_search'] == 'GartnerBladeGlass' ? %w[sku] : %w[sku title]
  # end

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
      remove_hmt(obj: f_val)
      #remove_hmt(f_val)
    end
  end

  # replace methods ############################################################
  # def replace_param(k, t, f_name, new_val, old_val, input_params)
  #   remove_param(k, t, f_name, old_val, input_params)
  #   add_param(k, t, f_name, new_val)
  # end

  # default add ################################################################
  # def add_default_fields(field_args)
  #   field_args.each do |f_hsh|
  #     add_default(*h_vals(f_hsh, :k, :t, :f_name, :f_val))
  #   end
  # end

  # def add_default(k, t, f_name, f_val)
  #   if f = default_field(k, t, f_val)
  #     add_field(k, f.type.underscore, f_name, f)
  #   end
  # end

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

  # methods moved from product.rb or item.rb ###################################
  def config_input_and_selected(k, t, f_name, f, input_group)
  	input_group[:inputs] << f_hsh(k, t, f_name, f)
  	set_selected_and_push(input_group, input_group[:i_params].dig(tag_key(k, t_type(t), f_name)))
  end
  
  def set_selected_and_push(input_group, selected_param)
    if selected_param
      input_group[:inputs][-1][:selected] = selected_param
    end
  end

  def pull_tags_and_return_fargs(f, input_group, k, t, f_name)
  	tag_key_loop(k, t, f_name, f, input_group[:tag_hsh])
  	[k, t, f_name]
  end

  def tag_key_loop(k, t, f_name, f, tag_hsh)
  	f.tags.map {|tag_key, v| Item.case_merge(tag_hsh, v, k, tag_key, f_name) if field_tag_keys.include?(tag_key)} if f.tags
  end

  def field_tag_keys
  	%w[tagline invoice_tagline tagline_search body material_dimension mounting_dimension material_mounting mounting_search]
  end

  def f_hsh(k, t, f_name, f)
    {k: k, t: t, t_type: f_assoc(t), f_name: f_name, f_val: f, selected: nil}
  end

  # basic utility methods ######################################################
  def tag_assoc(k, t, f_name, v2)
    {tag_key(k, t_type(t.underscore), f_name) => v2}
  end

  def t_type(t)
    if t=='select_field'
      'option'
    elsif t=='select_menu'
      'field_set'
    else
      t
    end
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
