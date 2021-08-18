class Dimension
  include ClassContext
  include FieldSeed
  include Hashable

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  def self.input_group
    [3, %w[dimension]]
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

end
