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

  def self.config_dimension(k, dimension_hsh, mounting_search, input_group, context)
  	config_dimension_params(k, dimension_hsh, get_measurements(dimension_hsh), mounting_search, input_group, context)
  end

  def self.config_dimension_params(k, dimension_hsh, measurements, mounting_search, input_group, context)
  	return if !measurements.has_key?(tags[0])
  	measurements.each {|dimension_key, measurement_hsh| format_measurement_values(dimension_key, *measurement_hsh.values, dimension_hsh, context, input_group[:attrs])}
    material_dimension, mounting_dimension = Dimension.tags.map{|key| dimension_hsh.dig(key)}
  	input_group[:attrs].merge!({'item_size'=> material_dimension['item_size'], 'measurements'=>material_dimension['measurements'], 'mounting_search'=>mounting_search})
  	Dimension.new.tb_dimensions(k, material_dimension, mounting_dimension)
  end

  def self.get_measurements(dimension_hsh)
  	Dimension.tags.each_with_object({}) do |dimension_key, measurements|
  		if measurement_hsh = dimension_hsh.dig(dimension_key, 'measurements')
  			config_valid_dimensions(dimension_key, dimension_hsh, get_dimensions(dimension_key, measurement_hsh), measurements)
  		end
  	end
  end

  def self.get_dimensions(dimension_key, measurement_hsh)
  	Dimension.public_send("#{dimension_key.split('_')[0]}_units").each_with_object({}){|unit_key, hsh| hsh[unit_key] = measurement_hsh[unit_key]}.reject{|k,v| v.blank?}
  end

  def self.config_valid_dimensions(dimension_key, dimension_hsh, dimensions, measurements)
  	if valid_dimensions = valid_dimension_values(dimensions.keys, dimensions.values)
  		measurements[dimension_key] = {:valid_dimensions=>valid_dimensions, :unit_values=>dimensions.values}
  	else
  		dimension_hsh.delete(dimension_key)
  	end
  end

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

  # tagline, body & attributes 26 ##############################################
  def tb_dimensions(k, material_dimensions, mounting_dimensions, tb_hsh={})
  	tagline_dimensions(k, (mounting_dimensions.present? ? mounting_dimensions : material_dimensions), tb_hsh)
  	body_dimensions(k, material_dimensions['measurements'], material_dimensions['tag'], mounting_dimensions, tb_hsh)
  	abbrv_dimensions(k, material_dimensions['measurements'], material_dimensions['tag'], mounting_dimensions, tb_hsh)
  	tb_hsh
  end

  def tagline_dimensions(k, dimension_hsh, d_hsh)
    if dimension_hsh.dig('item_size').to_i >= 1300
      Item.case_merge(d_hsh, "(#{dimension_hsh.dig('measurements')})", 'tagline')
    end
  end

  def body_dimensions(k, material_measurements, material_tag, mounting_dimensions, d_hsh)
    material_measurements = body_material_measurements(material_measurements, material_tag, (';' if material_tag && material_tag.index('weight')))
    measurements = ["Measures approx.", body_mounting_measurements(mounting_dimensions), material_measurements].compact.join(' ')
    Item.case_merge(d_hsh, measurements, 'body')
  end

  def abbrv_dimensions(k, material_measurements, material_tag, mounting_dimensions, d_hsh)
    measurements = [material_measurements, abbrv_mounting_measurements(mounting_dimensions)].compact
    measurements = measurements.count>1 ? measurements.join(' - ') : measurements[0]
    Item.case_merge(d_hsh, "(#{measurements})", 'invoice_tagline')
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
      mounting_tag = dimensions.slice!(1)
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

end

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
