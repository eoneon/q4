class Dimension
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
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

  #7
  def material_mounting_dimension_params(k_hsh, f_grp, args)
    if args[:k]!='dimension'
      material_mounting_params(args[:k], k_hsh, args[:related], args[:d_tag], args[:end_key], f_grp[:d_hsh], f_grp[:store])
    else
      dimension_params(k_hsh, f_grp, args)
    end
  end

  #6
  def material_mounting_params(k, k_hsh, related, d_tag, end_key, d_hsh, store)
    store[k] = slice_vals_and_delete(flatten_hsh(k_hsh), 'tagline', 'body') #tb_hsh
    if sub_tag = k_hsh.dig(d_tag)
      Item.case_merge(d_hsh, sub_tag, related, d_tag, end_key)
    end
  end

  #4
  def dimension_params(dimension, f_grp, args)
    if build_material_and_mounting_dimensions(dimension, f_grp[:attrs], args)
      tb_dimensions(args[:k], args[:material_dimensions], args[:mounting_dimensions], f_grp[:store])
    end
  end

  #10
  def build_material_and_mounting_dimensions(dimension, attrs, args)
    build_material_and_mounting_args(dimension, attrs, args)
    if material_dimensions = slice_dimensions(dimension, args[:material_dimension_keys])
      build_material_dimensions(material_dimensions.values, attrs, args)
      if mounting_dimensions = slice_dimensions(dimension, args[:mounting_dimension_keys])
        build_mounting_dimensions(dimension, mounting_dimensions.values, attrs, args)
      end
      args
    end
  end

  #9
  def build_material_and_mounting_args(dimension, attrs, args)
    if material_dimension = slice_and_delete(dimension, args[:d_tag])
      material, mounting = material_dimension.to_a
      build_material_args(dimension, material, args)
      if mounting_dimension = slice_and_delete(dimension, args[:d_tag2])
        build_mounting_args(dimension, mounting_dimension, mounting, args)
      end
    end
  end

  #4
  def build_material_args(dimension, material, args)
    args[:material_dimension_keys] = material[0].underscore.split('_')
    args[:material_tag] = material_tag(dimension, material[1], args)
  end

  def material_tag(dimension, material, args)
    if weight_key = slice_and_delete(args[:material_dimension_keys], 'weight')
      weight_params(dimension, weight_key)
    else
      material
    end
  end

  #5
  def weight_params(dimension, weight_key)
    if weight = slice_and_delete(dimension,weight_key)
      "#{weight}lbs (weight)" if weight.to_i >= 10
    end
  end

  #5
  def build_mounting_args(dimension, mounting_dimension, mounting, args)
    if args[:mounting_tag] = mounting_dimension.dig(args[:d_tag2])
      args[:mounting_dimension_keys] = mounting_dimension_keys(mounting[0].split('_'))
    end
  end

  #3
  def mounting_dimension_keys(mounting_keys)
    mounting_keys[1..-1].map{|d_name| [mounting_keys[0], d_name].join('_')}
  end

  #slice_present_vals
  def slice_dimensions(dimension, material_dimension_keys)
    slice_vals_and_delete(dimension, material_dimension_keys) if vals_exist?(dimension, material_dimension_keys)
  end

  #4
  def build_material_dimensions(material_dimension_values, attrs, args)
    args[:material_dimensions] = dimension_description_params(material_dimension_values, (args[:material_dimension_keys][0]=='diameter'), args[:material_tag])
    attrs.merge!([%w[width height], args[:material_dimensions].values[0..1]].transpose.to_h)
  end

  #4
  def build_mounting_dimensions(dimension, mounting_dimensions_values, attrs, args)
    args[:mounting_dimensions] = dimension_description_params(mounting_dimensions_values, nil, args[:mounting_tag])
    attrs.merge!([%w[frame_width frame_height], mounting_dimensions_values[0..1]].transpose.to_h) if args[:mounting_tag]=='(frame)'
  end

  # tagline, body & attributes 26 #################################################
  def tb_dimensions(k, material_dimensions, mounting_dimensions, store)
    tagline_dimensions(k, (mounting_dimensions.present? ? mounting_dimensions : material_dimensions), store)
    body_dimensions(k, material_dimensions['measurements'], material_dimensions['tag'], mounting_dimensions, store)
  end

  def tagline_dimensions(k, dimension_hsh, store)
    if dimension_hsh.dig('item_size').to_i >= 1300
      Item.case_merge(store, "(#{dimension_hsh.dig('measurements')})", k, 'tagline')
    end
  end

  def body_dimensions(k, material_measurements, material_tag, mounting_dimensions, store)
    material_measurements = material_measurements(material_measurements, material_tag, (';' if material_tag && material_tag.index('weight')))
    measurements = ["Measures approx.", mounting_measurements(mounting_dimensions), material_measurements].compact.join(' ')
    Item.case_merge(store, "Measures approx. #{measurements}", k, 'body')
  end

  def dimension_description_params(dimensions, diameter, dimension_tag)
    {'measurements'=> measurements(dimensions), 'item_size'=> item_size(dimensions[0..1], diameter), 'tag'=> dimension_tag}
  end

  def material_measurements(material_measurements, material_tag, punct)
    material_measurements = [material_measurements, punct].compact.join('')
    [material_measurements, material_tag].compact.join(' ')+'.'
  end

  def mounting_measurements(mounting_dimensions, keys=%w[measurements tag])
    if mounting_dimensions.present? && keys.none?{|k| mounting_dimensions.dig(k).blank?}
      puts "mounting_dimensions_143: #{mounting_dimensions}"
      keys.map{|k| mounting_dimensions[k]}.join(' ')+','
    end
  end

  def measurements(dims)
    dims.map{|i| i+"\""}.join(' x ')
  end

  def item_size(dims, dim_name=nil)
    dims = dims.map(&:to_i)
    dim_name == 'diameter' ? dims[0]**2 : dims.inject(:*)
  end
end
