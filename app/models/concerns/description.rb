require 'active_support/concern'

module Description
  extend ActiveSupport::Concern
  # i = Item.find(97)    d_hsh = i.input_group    i.description_hsh(i.input_group)

  def description_hsh(i_group)
    d_hsh = description_loop(i_group[:d_hsh], i_group[:store])
    #i_group[:attrs]
  end

  # def description_loop(d_hsh, store, tag_keys=%w[tagline body])
  #   d_hsh.each_with_object(store) do |(k, tb_hsh), store|
  #     k_hsh = tb_hsh.slice!(*tag_keys)
  #     tb_hsh.any? ? tb_hsh.transform_values!{|v_hsh| v_hsh.values[0]}.to_a : tb_hsh
  #     description_case(k, tb_hsh, k_hsh, store)
  #   end
  # end

  # def description_case(k, tb_set, k_hsh, store)
  #   case k
  #     when 'numbering'; numbering_case(k, tb_set, k_hsh, store)
  #     when 'dimension'; dimension_case(k_hsh, k, 'material_dimension', 'mounting_dimension', store)
  #     when 'dated'; dated_case(k, tb_set, k_hsh, store)
  #     when 'verification'; verification_case(k, tb_set, k_hsh, store)
  #     when 'disclaimer'; disclaimer_case(k, tb_set, k_hsh, store)
  #     else tb_set.map{|set| Item.case_merge(store, set[1], k, set[0])}
  #   end
  # end
  #
  # # numbering ##################################################################
  # def numbering_case(k, tb_set, k_hsh, store)
  #   ed_val = edition_value(k_hsh)
  #   tb_set.each_with_object(store) do |set,store|
  #     Item.case_merge(store, [set[1], ed_val].compact.join(' '), k, set[0])
  #   end
  # end
  #
  # def edition_value(k_hsh)
  #   if k_hsh.keys.count == 2
  #     k_hsh.values.join('/')
  #   elsif k_hsh.keys.include?('edition_size')
  #     "out of #{k_hsh['edition_size']}"
  #   end
  # end
  #
  # # dimension ##################################################################
  # def dimension_case(k_hsh, k, key, key2, store)
  #   dimension_hsh = k_hsh.slice!(key)
  #   f_name, dim_tag = k_hsh[key].to_a.flatten
  #   if material_hsh = valid_material_hsh?(dimension_hsh.slice!(*f_name.underscore.split('_')))
  #     h = material_dimension(dim_tag, material_hsh.keys[0], material_hsh.values, key)
  #     store[k] = h.merge!(mounting_dimension(dimension_hsh, key2))
  #   end
  # end
  #
  # def valid_material_hsh?(material_hsh)
  #   material_hsh if material_hsh.any? && (material_hsh.keys.count >= 2) || (material_hsh.keys.count == 1 && material_hsh.keys[0] == 'diameter')
  # end
  #
  # def material_dimension(dim_tag, dim_type, dim_vals, key)
  #   {key=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size(dim_type, dim_vals[0..1]), 'width'=> dim_vals[0..1][0], 'height'=> dim_vals[0..1][-1], 'tag'=> (dim_tag == 'n/a' ? nil : dim_tag)}}
  # end
  #
  # def mounting_dimension(mounting_hsh, key2)
  #   return {} unless mounting_hsh && mounting_hsh.values.count > 1
  #   dim_vals = mounting_hsh.values
  #   {key2=> {'measurements'=> measurements(dim_vals), 'item_size'=> item_size('mounting', dim_vals[0..1]), 'frame_width'=> dim_vals[0..1][0], 'frame_height'=> dim_vals[0..1][-1]}}
  # end
  #
  # def item_size(dim_name, dims)
  #   dims = dims.map(&:to_i)
  #   dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  # end
  #
  # def measurements(d_names)
  #   d_names.map{|i| i+"\""}.join(' x ')
  # end
  #
  # # dated ######################################################################
  # def dated_case(k, tb_set, k_hsh, store)
  #   return if tb_set.none? && k_hsh.none?
  #   tb_set.map{|set| Item.case_merge(store, [set[1], "(#{k_hsh.values[0]})"].join(' '), k, set[0])}
  # end
  #
  # # verification ###############################################################
  # def verification_case(k, tb_set, k_hsh, store)
  #   return if tb_set.none? && k_hsh.none?
  #   tb_set.map{|set| Item.case_merge(store, [set[1], "#{k_hsh.values[0]}"].join(' '), k, set[0])}
  # end
  #
  # # disclaimer #################################################################
  # def disclaimer_case(k, tb_set, k_hsh, store)
  #   return if tb_set.none? && k_hsh.none?
  #   tb_set.each do |set|
  #     v = set[0] == 'body' ? disclaimer(set[1], k_hsh.values[0]) : set[1]
  #     Item.case_merge(store, v, k, set[0])
  #   end
  # end
  #
  # def disclaimer(severity, damage)
  #   case severity
  #     when 'danger'; "** Please note: #{damage}. **"
  #     when 'warning'; "Please note: #{damage}."
  #     when 'notation'; damage
  #   end
  # end
  #
  # def oversized?(d_hsh, k='dimension', key='material_dimension', key2='mounting_dimension')
  #   d_hsh.dig(k,(framed?(d_hsh) ? key2 : key), 'item_size') >= 1300
  # end
  #
  # def tagline_keys
  #   %w[artist title mounting embellishing category edition_type medium material dimension leafing remarque numbering signature certificate disclaimer]
  # end
  #
  # def body_keys
  #   %w[title text_before_coa embellishing category edition_type medium sculpture_type material leafing remarque artist dated numbering signature verification text_before_coa mounting seal certificate dimension disclaimer]
  # end

end

# def untitled?(h)
#   h.dig('title', 'tagline').blank?
# end

# def category?(h)
#   h['edition_type'] || h['category']
# end

# title_params ###############################################################
# def title_params(d_hsh, store)
#   if store.dig('artist', 'tagline') == 'GartnerBlade'
#     gartner_blade_title(d_hsh, store)
#   else
#     store.merge!({'title'=> {'tagline'=> tagline_title, 'body'=> body_title}})
#   end
# end
#
# def tagline_title
#   "\"#{self.title}\"" unless self.title.blank?
# end
#
# def body_title
#   tagline_title ? tagline_title : 'This' #self.title.blank? ? 'This' : tagline_title
# end
#
# def attrs_title
#   tagline_title ? tagline_title : 'Untitled' #self.title.blank? ? 'Untitled' : "\"#{self.title}\""
# end
#
# def gartner_blade_title(d_hsh, store)
#   title_val = Sculpture.input_group.last.map{|k| d_hsh[k]['tagline']}.reject{|i| i.blank?}
#   if title_val.any?
#     store.merge!({'title'=> {'tagline'=> "\"#{title_val.join(' ')}\"" , 'body'=> "\"#{title_val.join(' ')}\""}})
#   end
# end

# def item_fields_hsh(input_params)
#   h = input_params.each_with_object({}) do |(k, field_groups), h|
#     field_groups.each do |t, fields|
#       if option?(t) && field_groups.one? && fields.one?
#         h[k] = fields.values[0].field_name
#       elsif dimension?(k) && tag_attr?(t)
#         dimension_hsh(h, k, fields.reject{|i| i.blank?})
#       elsif numbering?(k) && tag_attr?(t)
#       end
#     end
#   end
# end
