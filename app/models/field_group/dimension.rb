class Dimension
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, field_name: -1}
  end

  def self.material_units
    %w[width height depth diameter]
  end

  def self.mounting_units
    %w[mounting_width mounting_height]
  end

  def self.tags
    %w[material_dimension mounting_dimension]
  end

  def self.related_kinds
    %w[material mounting dimension]
  end

  # def self.config_dimension(k, dimension_hsh, input_group, context, d_hsh)
  #   config_dimension_hsh(dimension_hsh, context, input_group[:attrs])
  #   puts "dimension_hsh=>#{dimension_hsh}"
  #   material_dimension, mounting_dimension = Dimension.tags.map{|key| dimension_hsh.dig(key)}
  #   input_group[:attrs].merge!({'item_size'=> material_dimension['item_size'], 'measurements'=>material_dimension['measurements'], 'mounting_search'=>d_hsh.dig('mounting', 'mounting_search')})
  #   Dimension.new.tb_dimensions(k, material_dimension, mounting_dimension, d_hsh)
  # end

  def self.config_dimension(k, measurements, dimension_hsh, input_group, context, d_hsh)
  	return if !measurements.has_key?(tags[0])
  	measurements.each {|dimension_key, measurement_hsh| format_measurement_values(dimension_key, *measurement_hsh.values, dimension_hsh, context, attrs)}
  	material_dimension, mounting_dimension = Dimension.tags.map{|key| dimension_hsh.dig(key)}
  	input_group[:attrs].merge!({'item_size'=> material_dimension['item_size'], 'measurements'=>material_dimension['measurements'], 'mounting_search'=>d_hsh.dig('mounting', 'mounting_search')})
  	Dimension.new.tb_dimensions(k, material_dimension, mounting_dimension, d_hsh)
  end

  ## I
  def self.get_measurements(dimension_hsh)
  	Dimension.tags.each_with_object({}) do |dimension_key, measurements|
  		if measurement_hsh = dimension_hsh.dig(dimension_key, 'measurements')
  			config_valid_dimensions(dimension_key, dimension_hsh, get_dimensions(dimension_key, measurement_hsh), measurements)
  		end
  	end
  end

  ## II
  def self.get_dimensions(dimension_key, measurement_hsh)
  	Dimension.public_send("#{dimension_key.split('_')[0]}_units").each_with_object({}){|unit_key, hsh| hsh[unit_key] = measurement_hsh[unit_key]}.reject{|k,v| v.blank?}
  end

  ## III
  def self.config_valid_dimensions(dimension_key, dimension_hsh, dimensions, measurements)
  	if valid_dimensions = valid_dimension_values(dimensions.keys, dimensions.values)
  		measurements[dimension_key] = {:valid_dimensions=>valid_dimensions, :unit_values=>dimensions.values}
  	else
  		dimension_hsh.delete(dimension_key)
  	end
  end

  ## V
  def self.format_measurement_values(dimension_key, valid_dimensions, unit_values, dimension_hsh, context, attrs)
  	dimension_hsh[dimension_key]['item_size'] = valid_dimensions.map(&:to_i).inject(:*)
  	dimension_hsh[dimension_key]['measurements'] = format_measurements(unit_values)
  	dimension_attrs(dimension_key, valid_dimensions, context[:framed], attrs)
  end

  def self.measurement_hsh(tag_hsh, selected, k, f_name, key='measurements')
    if dimension_tag = dimension_tag(f_name)
      Item.case_merge(tag_hsh, selected, k, dimension_tag, key, f_name)
    end
  end

  def self.dimension_tag(f_name)
  	if material_units.include?(f_name)
  		tags[0]
  	elsif mounting_units.include?(f_name)
  		tags[1]
  	end
  end

  # def self.config_dimension_hsh(dimension_hsh, context, attrs)
  #   puts "dimension_hsh=>#{dimension_hsh}"
  #   Dimension.tags.each_with_object(dimension_hsh) do |dimension_key|
  #     if measurement_hsh = dimension_hsh.dig(dimension_key, 'measurements')
  #
  #       dimensions = Dimension.public_send("#{dimension_key.split('_')[0]}_units").each_with_object({}){|unit_key, hsh| hsh[unit_key] = measurement_hsh[unit_key]}.reject{|k,v| v.blank?}
  #       if valid_dimensions = valid_dimension_values(dimensions.keys, dimensions.values)
  #         format_measurement_values(dimension_key, dimensions.values, dimension_hsh, valid_dimensions, context, attrs)
  #       else
  #         dimension_hsh[dimension_key].clear
  #         #dimension_hsh.delete(dimension_key)
  #       end
  #     end
  #   end
  # end
  #
  # def self.format_measurement_values(dimension_key, unit_values, dimension_hsh, valid_dimensions, context, attrs)
	# 	dimension_hsh[dimension_key]['item_size'] = valid_dimensions.map(&:to_i).inject(:*)
	# 	dimension_hsh[dimension_key]['measurements'] = format_measurements(unit_values)
	# 	dimension_attrs(dimension_key, valid_dimensions, context[:framed], attrs)
  # end

  # def self.config_dimension_hsh(dimension_hsh, context, attrs)
  # 	Dimension.tags.each_with_object(dimension_hsh) do |dimension_key|
  # 		if measurement_hsh = dimension_hsh.dig(dimension_key, 'measurements')
  # 			dimensions = Dimension.public_send("#{dimension_key.split('_')[0]}_units").each_with_object({}){|unit_key, hsh| hsh[unit_key] = measurement_hsh[unit_key]}.reject{|k,v| v.blank?}
  #       format_measurement_values(dimension_key, dimensions.keys, dimensions.values, dimension_hsh, context, attrs)
  # 		end
  # 	end
  # end

  # def self.format_measurement_values(dimension_key, unit_keys, unit_values, dimension_hsh, context, attrs)
  # 	if valid_dimensions = valid_dimension_values(unit_keys, unit_values)
  # 		dimension_hsh[dimension_key]['item_size'] = valid_dimensions.map(&:to_i).inject(:*)
  # 		dimension_hsh[dimension_key]['measurements'] = format_measurements(unit_values)
  # 		dimension_attrs(dimension_key, valid_dimensions, context[:framed], attrs)
  # 	end
  # end

  def self.valid_dimension_values(unit_keys, unit_values)
  	if unit_keys.count==1 && unit_keys[0]=='diameter'
  		[unit_values[0], unit_values[0]]
  	elsif unit_values.count>=2
  		unit_values[0..1]
  	end
  end

  def self.dimension_attrs(dimension_key, valid_dimensions, framed, attrs)
    if units = attr_keys(dimension_key, framed)
      units.each_with_index{|unit,i| attrs[unit] = valid_dimensions[i]}
    end
  end

  def self.attr_keys(dimension_key, framed)
  	if dimension_key=='material_dimension'
  		%w[width height]
  	elsif dimension_key=='mounting_dimension' && framed
  		%w[frame_width frame_height]
  	end
  end

  def self.format_measurements(dims)
    dims.map{|i| i+"\""}.join(' x ')
  end

  def self.item_size(dims, dim_name=nil)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end

  class FieldSet < Dimension
    class FlatArt < FieldSet
      def self.name_values
        {material_dimension: '(image)'}
      end

      class WidthHeight < FlatArt
        def self.targets
          build_target_group(%W[Width Height], 'NumberField', 'Dimension')
        end
      end

      class WidthHeightDepth < FlatArt
        def self.name_values
          {material_dimension: 'n/a'}
        end

        def self.targets
          build_target_group(%W[Width Height Depth], 'NumberField', 'Dimension')
        end
      end

      class Diameter < FlatArt
        def self.name_values
          {material_dimension: '(image-diameter)'}
        end

        def self.targets
          [%W[NumberField Dimension Diameter]]
        end
      end
    end

    class FlatMounting < FieldSet
      def self.name_values
        {material_dimension: 'n/a'}
      end

      class MountingWidthHeight < FlatMounting
        def self.targets
          build_target_group(%W[MountingWidth MountingHeight], 'NumberField', 'Dimension')
        end
      end
    end

    class DepthArt < FieldSet
      def self.name_values
        {material_dimension: 'n/a'}
      end

      class WidthHeightDepthWeight < DepthArt
        def self.targets
          build_target_group(%W[Width Height Depth Weight], 'NumberField', 'Dimension')
        end
      end

      class DiameterHeightWeight < DepthArt
        def self.targets
          build_target_group(%W[Diameter Height Weight], 'NumberField', 'Dimension')
        end
      end

      class DiameterWeight < DepthArt
        def self.name_values
          {material_dimension: '(diameter)'}
        end

        def self.targets
          build_target_group(%W[Diameter Weight], 'NumberField', 'Dimension')
        end
      end
    end

  end

  class SelectMenu < Dimension
    class FlatArt < SelectMenu
      class FlatDimension < FlatArt
        def self.targets
          build_target_group(%W[WidthHeight Diameter], 'FieldSet', 'Dimension')
        end
      end

      class CanvasDimension < FlatArt
        def self.targets
          [%W[FieldSet Dimension WidthHeight]]
        end
      end
    end

    class DepthArt < SelectMenu
      class DepthDimension < DepthArt
        def self.targets
          build_target_group(%W[WidthHeightDepthWeight DiameterHeightWeight DiameterWeight], 'FieldSet', 'Dimension')
        end
      end
    end

  end

  # def config_dimension_params(k, dimension_hsh, d_hsh, context, attrs)
  #   config_dimension_hsh(dimension_hsh, context, attrs)
  #   tb_dimensions(k, *Dimension.tags.map{|key| dimension_hsh.dig(key)}, d_hsh)
  # end

  ##############################################################################
  # def config_related_params(related_hsh, d_hsh, context, attrs)
  # 	related_hsh.keys.each do |k|
  # 		if k_hsh = related_hsh.dig(k)
  # 			config_param(k, k_hsh, d_hsh, context, attrs)
  # 			if tagline_val = k_hsh.dig('tagline')
  # 				config_context(k, tagline_val, context)
  # 			end
  # 		end
  # 	end
  # end

  # def config_related_params(related_hsh, d_hsh, context, attrs)
  # 	related_hsh.each_with_object(d_hsh) do |(k, k_hsh), d_hsh|
  # 		config_param(k, k_hsh, d_hsh)
  # 		if tagline_val = k_hsh.dig('tagline')
  # 			config_context(k, tagline_val, context)
  # 		end
  # 	end
  # end

  # def config_param(k, k_hsh, d_hsh, context, attrs)
  # 	if k == 'dimension'
  # 		config_dimension_hsh(k_hsh, context, attrs)
  # 		tb_dimensions(k, *Dimension.tags.map{|key| k_hsh.dig(key)}, d_hsh)
  # 	else
  # 		d_hsh[k] = k_hsh
  # 	end
  # end

  #b
  # def config_param(k, k_hsh, d_hsh)
  # 	if k == 'dimension'
  # 		config_dimension_hsh(k_hsh)
  # 		tb_dimensions(k, *Dimension.tags.map{|key| k_hsh.dig(key)}, d_hsh)
  # 	else
  # 		d_hsh[k] = k_hsh
  # 	end
  # end

  # def config_dimension_hsh(dimension_hsh, context, attrs)
  # 	Dimension.tags.each_with_object(dimension_hsh) do |dimension_key|
  # 		if measurement_hsh = dimension_hsh.dig(dimension_key, 'measurements')
  # 			dimensions = Dimension.public_send("#{dimension_key.split('_')[0]}_units").each_with_object({}){|unit_key, hsh| hsh[unit_key] = measurement_hsh[unit_key]}.reject{|k,v| v.blank?}
  #       unit_keys, unit_values = dimensions.keys, dimensions.values
  #       format_measurement_values(dimension_key, unit_keys, unit_values, dimension_hsh, context, attrs)
  # 		end
  # 	end
  # end

  # def format_measurement_values(dimension_key, unit_keys, unit_values, dimension_hsh, context, attrs)
  # 	if valid_dimensions = valid_dimension_values(unit_keys, unit_values)
  # 		dimension_hsh[dimension_key]['item_size'] = valid_dimensions.map(&:to_i).inject(:*)
  # 		dimension_hsh[dimension_key]['measurements'] = format_measurements(unit_values)
  # 		dimension_attrs(dimension_key, valid_dimensions, context[:framed], attrs)
  # 	end
  # end

  # def valid_dimension_values(unit_keys, unit_values)
  # 	if unit_keys.count==1 && unit_keys[0]=='diameter'
  # 		[unit_values[0], unit_values[0]]
  # 	elsif unit_values.count>=2
  # 		unit_values[0..1]
  # 	end
  # end

  # def dimension_attrs(dimension_key, valid_dimensions, framed, attrs)
  #   if units = attr_keys(dimension_key, framed)
  #     units.each_with_index{|unit,i| attrs[unit] = valid_dimensions[i]}
  #   end
  # end

  # def attr_keys(dimension_key, framed)
  # 	if dimension_key=='material_dimension'
  # 		%w[width height]
  # 	elsif dimension_key=='mounting_dimension' && framed
  # 		%w[frame_width frame_height]
  # 	end
  # end

  #c
  # def config_context(k, tagline_val, context)
  # 	if context_key = related_context(k, tagline_val)
  # 		context[context_key] = true
  # 	end
  # end

  # def config_context(k, tagline_val, context)
  #   context[k.to_sym] = true unless k=='mounting'
  #   if context_key = related_context(k, tagline_val)
  #     context[context_key] = true
  #   end
  # end

  #d
  # def related_context(k, tagline_val)
  # 	if i = ['Framed', 'Gallery Wrapped', 'Rice', 'Paper'].detect{|i| tagline_val.index(i)}
  # 		Item.new.symbolize(i)
  # 	end
  # end

  # def config_dimension_hsh(dimension_hsh)
  # 	Dimension.tags.each_with_object(dimension_hsh) do |k|
  # 		if measurement_hsh = dimension_hsh.dig(k, 'measurements')
  #       keys, values = Dimension.public_send("#{k.split('_')[0]}_units").each_with_object({}){|(key,val), hsh| hsh[key] = measurement_hsh[key]}.to_a
  #       dimension_hsh[k]['item_size'] = item_size(values[0..1], (keys.count==1 && keys[0]=='diameter' ? 'diameter' :nil))
  # 			dimension_hsh[k]['measurements'] = format_measurements(values)
  # 		end
  # 	end
  # end

  #dims.map(&:to_i).inject(:*)
  ##############################################################################

  # def material_mounting_dimension_params(k_hsh, f_grp, args)
  #   if args[:k]!='dimension'
  #     material_mounting_params(args[:k], k_hsh, args[:related], args[:d_tag], args[:end_key], f_grp)
  #   else
  #     dimension_params(k_hsh, f_grp, args)
  #   end
  # end

  # def material_mounting_params(k, k_hsh, related, d_tag, end_key, f_grp)
  #   #transfer_description_vals(k, flatten_hsh(k_hsh), f_grp[:attrs], f_grp[:store])
  #   transfer_description_vals(k, k_hsh, f_grp[:attrs], f_grp[:store])
  #   if sub_tag = k_hsh.dig(d_tag)
  #     Item.case_merge(f_grp[:d_hsh], sub_tag, related, d_tag, end_key)
  #   end
  # end

  # def transfer_description_vals(k, hsh, attrs, store)
  #   slice_and_transfer(h: hsh, h2: store, keys: %w[tagline invoice_tagline search_tagline body], k: k)
  #   slice_and_transfer(h: hsh, h2: attrs, keys: ['mounting_search'])
  # end

  # def dimension_params(dimension, f_grp, args)
  #   if build_material_and_mounting_dimensions(dimension, f_grp[:attrs], args)
  #     tb_dimensions(args[:k], args[:material_dimensions], args[:mounting_dimensions], f_grp[:store])
  #   end
  # end

  # def build_material_and_mounting_dimensions(dimension, attrs, args)
  #   build_material_and_mounting_args(dimension, attrs, args)
  #   if material_dimensions = slice_dimensions(dimension, args[:material_dimension_keys])
  #     build_material_dimensions(material_dimensions.values, attrs, args)
  #     if mounting_dimensions = slice_dimensions(dimension, args[:mounting_dimension_keys])
  #       build_mounting_dimensions(dimension, mounting_dimensions.values, attrs, args)
  #     end
  #     args
  #   end
  # end

  # def build_material_and_mounting_args(dimension, attrs, args)
  #   if material_dimension = slice_and_delete(dimension, args[:d_tag])
  #     material, mounting = material_dimension.to_a
  #     build_material_args(dimension, material, args)
  #     if mounting_dimension = slice_and_delete(dimension, args[:d_tag2])
  #       build_mounting_args(dimension, mounting_dimension, mounting, args)
  #     end
  #   end
  # end

  # def build_material_args(dimension, material, args)
  #   args[:material_dimension_keys] = material[0].underscore.split('_')
  #   args[:material_tag] = material_tag(dimension, material[1], args)
  # end

  # def material_tag(dimension, material, args)
  #   if weight_key = slice_and_delete(args[:material_dimension_keys], 'weight')
  #     weight_params(dimension, weight_key)
  #   else
  #     material
  #   end
  # end

  # def weight_params(dimension, weight_key)
  #   if weight = slice_and_delete(dimension,weight_key)
  #     "#{weight}lbs (weight)" if weight.to_i >= 10
  #   end
  # end

  # def build_mounting_args(dimension, mounting_dimension, mounting, args)
  #   if args[:mounting_tag] = mounting_dimension.dig(args[:d_tag2])
  #     args[:mounting_dimension_keys] = mounting_dimension_keys(mounting[0].split('_'))
  #   end
  # end

  # def mounting_dimension_keys(mounting_keys)
  #   mounting_keys[1..-1].map{|d_name| [mounting_keys[0], d_name].join('_')}
  # end

  # def slice_dimensions(dimension, material_dimension_keys)
  #   slice_vals_and_delete(dimension, material_dimension_keys) if vals_exist?(dimension, material_dimension_keys)
  # end

  # def build_material_dimensions(material_dimension_values, attrs, args)
  #   attrs.merge!([%w[width height], material_dimension_values[0..1]].transpose.to_h)
  #   args[:material_dimensions] = dimension_description_params(material_dimension_values, (args[:material_dimension_keys][0]=='diameter'), args[:material_tag])
  #   attrs.merge!(args[:material_dimensions].slice('measurements', 'item_size'))
  # end

  # def build_mounting_dimensions(dimension, mounting_dimensions_values, attrs, args)
  #   args[:mounting_dimensions] = dimension_description_params(mounting_dimensions_values, nil, args[:mounting_tag])
  #   attrs.merge!([%w[frame_width frame_height], mounting_dimensions_values[0..1]].transpose.to_h) if args[:mounting_tag]=='(frame)'
  # end

  # tagline, body & attributes 26 ##############################################
  def tb_dimensions(k, material_dimensions, mounting_dimensions, d_hsh)
    tagline_dimensions(k, (mounting_dimensions.present? ? mounting_dimensions : material_dimensions), d_hsh)
    body_dimensions(k, material_dimensions['measurements'], material_dimensions['tag'], mounting_dimensions, d_hsh)
    abbrv_dimensions(k, material_dimensions['measurements'], material_dimensions['tag'], mounting_dimensions, d_hsh)
  end

  def tagline_dimensions(k, dimension_hsh, d_hsh)
    if dimension_hsh.dig('item_size').to_i >= 1300
      Item.case_merge(d_hsh, "(#{dimension_hsh.dig('measurements')})", k, 'tagline')
    end
  end

  def body_dimensions(k, material_measurements, material_tag, mounting_dimensions, d_hsh)
    material_measurements = body_material_measurements(material_measurements, material_tag, (';' if material_tag && material_tag.index('weight')))
    measurements = ["Measures approx.", body_mounting_measurements(mounting_dimensions), material_measurements].compact.join(' ')
    Item.case_merge(d_hsh, measurements, k, 'body')
  end

  def abbrv_dimensions(k, material_measurements, material_tag, mounting_dimensions, d_hsh)
    measurements = [material_measurements, abbrv_mounting_measurements(mounting_dimensions)].compact
    measurements = measurements.count>1 ? measurements.join(' - ') : measurements[0]
    Item.case_merge(d_hsh, "(#{measurements})", k, 'invoice_tagline')
  end

  def dimension_description_params(dimensions, diameter, dimension_tag)
    {'measurements'=> format_measurements(dimensions), 'item_size'=> item_size(dimensions[0..1], diameter), 'tag'=> dimension_tag}
  end

  def body_material_measurements(material_measurements, material_tag, punct=nil)
    material_measurements = [material_measurements, punct].compact.join('')
    [material_measurements, material_tag].compact.join(' ')+'.'
  end

  def body_mounting_measurements(mounting_dimensions)
    if dimensions = valid_mounting_measurements(mounting_dimensions)
      dimensions.join(' ')+','
    end
  end

  def abbrv_mounting_measurements(mounting_dimensions)
    if dimensions = valid_mounting_measurements(mounting_dimensions)
      mounting_tag = dimensions.slice!(1) #.reverse.join(' ')
      [dimensions, abbrv_mounting_tag(mounting_tag)].join(' ')
    end
  end

  def abbrv_mounting_tag(mounting_tag)
    if set = [%w[frame frm], %w[border bdr], %w[matting mat]].detect{|set| mounting_tag.index(set[0])}
      set[1]
    end
  end

  def valid_mounting_measurements(mounting_dimensions, keys=%w[measurements tag])
    keys.map{|k| mounting_dimensions[k]} if mounting_dimensions.present? && keys.none?{|k| mounting_dimensions.dig(k).blank?}
  end

  # def format_measurements(dims)
  #   dims.map{|i| i+"\""}.join(' x ')
  # end
  #
  # def item_size(dims, dim_name=nil)
  #   dims = dims.map(&:to_i)
  #   dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  # end
end

# def material_mounting_params(k, k_hsh, related, d_tag, end_key, d_hsh, store)
#   #store[k] = slice_vals_and_delete(flatten_hsh(k_hsh), 'tagline', 'body')
#   #slice_and_transfer(h: flatten_hsh(k_hsh), h2: store, keys: ['tagline', 'body'], k: k)
#   #slice_and_transfer(h: flatten_hsh(k_hsh), h2: attrs, keys: ['mounting_search'])
#   abbr_material(k, store)
#   if sub_tag = k_hsh.dig(d_tag)
#     Item.case_merge(d_hsh, sub_tag, related, d_tag, end_key)
#   end
# end
#
# def abbr_material(k, store)
#   if k=='material' && %w[stretched paper].detect{|str| store[k]['body'].index(str)}
#     Item.case_merge(store, Item.str_edit(str: store[k]['body'], skip: ['on']), k, 'abbrv')
#   end
# end
