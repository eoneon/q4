class Dimension
  include ClassContext
  include FieldSeed

  def self.cascade_build(store)
    f_kind, f_type, f_name = f_attrs(0, 1, 3)
    add_field_group(to_class(f_type), self, f_type, f_kind, f_name, store)
  end

  class FieldSet < Dimension

    class FlatArt < FieldSet

      class WidthHeight < FlatArt
        def self.targets
          build_target_group(%W[Width Height], 'NumberField', 'Dimension')
        end
      end

      class WidthHeightDepth < FlatArt
        def self.targets
          build_target_group(%W[Width Height Depth], 'NumberField', 'Dimension')
        end
      end

      class Diameter < FlatArt
        def self.targets
          [%W[NumberField Dimension Diameter]]
        end
      end
    end

    class FlatMounting < FieldSet
      class MountingWidthHeight < FlatMounting
        def self.targets
          build_target_group(%W[MountingWidth MountingHeight], 'NumberField', 'Dimension')
        end
      end
    end

    class DepthArt < FieldSet
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


  # def self.cascade_build(class_a, class_b, class_c, class_d, store)
  #   f_kind, f_type, f_name = [class_a, class_b, class_d].map(&:const)
  #   add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store)
  # end
