class Material
  extend Context
  extend FieldKind

  def self.cascade_build(class_a, class_b, class_c, class_d, store)
    f_kind, f_type, subkind, f_name = [class_a, class_b, class_c, class_d].map(&:const)
    tags = class_b.method_exists?(:tag_set) ? build_tags(args: {subkind: subkind, f_name: f_name}, tag_set: class_b.tag_set, class_set: [class_d, class_c, class_b]) : nil
    add_field_group(to_class(f_type), class_d, f_type, f_kind, f_name, store, tags)
  end

  class SelectField < Material

    def self.tag_set
      [:product_name, :search, :material_attr]
    end

    def self.product_name(subkind, f_name)
      class_to_cap(f_name.sub('Standard', ''))
    end

    def self.search(subkind, f_name)
      f_name.sub('Standard', '')
    end

    def self.material_attr(subkind, f_name)
      subkind
    end

    class Canvas < SelectField
      class StandardCanvas < Canvas
        def self.targets
          ['canvas', 'canvas board', 'textured canvas']
        end
      end

      class WrappedCanvas < Canvas
        def self.targets
          ['gallery wrapped canvas', 'stretched canvas']
        end
      end
    end

    class Paper < SelectField
      class StandardPaper < Paper
        def self.targets
          ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'archival paper', 'museum quality paper', 'sommerset paper', 'mother of pearl paper']
        end
      end

      class PhotoPaper < Paper
        def self.product_name(subkind, f_name)
          'Paper'
        end

        def self.targets
          ['paper', 'photography paper', 'archival grade paper']
        end
      end

      class AnimationPaper < Paper
        def self.targets
          ['paper', 'animation paper']
        end
      end
    end

    class Board < SelectField
      class StandardBoard < Board
        def self.targets
          ['board', 'wood board', 'masonite']
        end
      end

      class Wood < Board
        def self.targets
          ['wood', 'wood panel', 'board', 'panel']
        end
      end

      class WoodBox < Board
        def self.targets
          ['wood box']
        end
      end

      class Acrylic < Board
        def self.targets
          ['acrylic', 'acrylic panel', 'resin']
        end
      end
    end

    class Metal < SelectField
      class StandardMetal < Metal
        def self.targets
          ['metal', 'metal panel', 'aluminum', 'aluminum panel']
        end
      end

      class MetalBox < Metal
        def self.targets
          ['metal box']
        end
      end
    end

  end

  class FieldSet < Material
    class CanvasMaterial < FieldSet
      class StandardCanvas < CanvasMaterial
        def self.targets
          [%W[SelectField Material Canvas], %W[FieldSet Dimension WidthHeight], %W[SelectMenu Mounting CanvasMounting]]
        end
      end

      class WrappedCanvas < CanvasMaterial
        def self.targets
          [%W[SelectField Material WrappedCanvas], %W[FieldSet Dimension WidthHeight]]
        end
      end
    end

    class StandardMaterial < FieldSet
      class StandardPaper < StandardMaterial
        def self.targets
          [%W[SelectField Material StandardPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class PhotoPaper < StandardMaterial
        def self.targets
          [%W[SelectField Material PhotoPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class AnimationPaper < StandardMaterial
        def self.targets
          [%W[SelectField Material AnimationPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class StandardWood < StandardMaterial
        def self.targets
          [%W[SelectField Material Wood], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class Board < StandardMaterial
        def self.targets
          [%W[SelectField Material StandardBoard], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class Acrylic < StandardMaterial
        def self.targets
          [%W[SelectField Material Acrylic], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class StandardMetal < StandardMaterial
        def self.targets
          [%W[SelectField Material StandardMetal], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end
    end

    class BoxMaterial < FieldSet
      class WoodBox < BoxMaterial
        def self.targets
          [%W[SelectField Material WoodBox], %W[FieldSet Dimension WidthHeightDepth]]
        end
      end

      class MetalBox < BoxMaterial
        def self.targets
          [%W[SelectField Material MetalBox], %W[FieldSet Dimension WidthHeightDepth]]
        end
      end
    end
  end

  # class FieldSet < Material
  #   class Canvas < FieldSet
  #     class StandardCanvas < Canvas
  #       def self.targets
  #         [%W[SelectField Material Canvas], %W[FieldSet Dimension WidthHeight], %W[SelectMenu Mounting CanvasMounting]]
  #       end
  #     end
  #
  #     class WrappedCanvas < Canvas
  #       def self.targets
  #         [%W[SelectField Material WrappedCanvas], %W[FieldSet Dimension WidthHeight]]
  #       end
  #     end
  #   end
  #
  #   class Paper < FieldSet
      # class StandardPaper < Paper
      #   def self.targets
      #     [%W[SelectField Material StandardPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
      #   end
      # end
      #
      # class PhotoPaper < Paper
      #   def self.targets
      #     [%W[SelectField Material PhotoPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
      #   end
      # end
      #
      # class AnimationPaper < Paper
      #   def self.targets
      #     [%W[SelectField Material AnimationPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
      #   end
      # end
  #   end
  #
  #   class Wood < FieldSet
  #     class StandardWood < Wood
  #       def self.targets
  #         [%W[SelectField Material Wood], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
  #       end
  #     end
  #
  #     class WoodBox < Wood
  #       def self.targets
  #         [%W[SelectField Material WoodBox], %W[FieldSet Dimension WidthHeightDepth]]
  #       end
  #     end
  #
  #     class Board < Wood
  #       def self.targets
  #         [%W[SelectField Material Board], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
  #       end
  #     end
  #
  #     class Acrylic < Wood
  #       def self.targets
  #         [%W[SelectField Material Acrylic], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
  #       end
  #     end
  #   end
  #
  #   class Metal < FieldSet
  #     class StandardMetal < Metal
  #       def self.targets
  #         [%W[SelectField Material StandardMetal], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
  #       end
  #     end
  #
  #     class MetalBox < Metal
  #       def self.targets
  #         [%W[SelectField Material MetalBox], %W[FieldSet Dimension WidthHeightDepth]]
  #       end
  #     end
  #   end
  #
  #
  # end
end
