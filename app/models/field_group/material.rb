class Material
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store, build_tags(args, :product_name, :search, :material_attr))
  end

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  class SelectField < Material

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

    # def self.assoc_group
    #   kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
    #   merge_enum(:targets, :group).each_with_object({}) do |(k,v), assocs|
    #     case_merge(assocs, k, v, kind, type)
    #   end
    # end

    def self.assoc_group
      kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
      merge_enum(:targets, :group, kind, type)
    end

    def self.product_name(args)
      class_to_cap(args[:f_name].sub('Standard', ''))
    end

    def self.search(args)
      args[:subkind]
    end

    def self.medium_attr(args)
      args[:f_name]
    end

    class Canvas < FieldSet

      def self.group
        [:OnStandard, :OnCanvas, :OnPaperAndCanvas]
      end

      class StandardCanvas < Canvas
        def self.targets
          [%W[SelectField Material Canvas], %W[FieldSet Dimension WidthHeight], %W[SelectMenu Mounting CanvasMounting]]
        end
      end

      class WrappedCanvas < Canvas
        def self.targets
          [%W[SelectField Material WrappedCanvas], %W[FieldSet Dimension WidthHeight]]
        end
      end
    end

    class Paper < FieldSet
      class StandardPaper < Paper
        def self.group
          [:OnStandard, :OnPaper, :OnPaperAndCanvas]
        end

        def self.targets
          [%W[SelectField Material StandardPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class PhotoPaper < Paper
        def self.group
          [:OnPhotoPaper]
        end

        def self.targets
          [%W[SelectField Material PhotoPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class AnimationPaper < Paper
        def self.group
          [:OnAnimationPaper]
        end

        def self.targets
          [%W[SelectField Material AnimationPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end
    end

    class Board < FieldSet
      def self.group
        [:OnStandard]
      end

      class StandardBoard < Board
        def self.targets
          [%W[SelectField Material StandardBoard], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class Wood < Board
        def self.targets
          [%W[SelectField Material Wood], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class WoodBox < Board
        def self.targets
          [%W[SelectField Material WoodBox], %W[FieldSet Dimension WidthHeightDepth]]
        end
      end

      class Acrylic < Board
        def self.targets
          [%W[SelectField Material Acrylic], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end
    end

    class Metal < FieldSet
      def self.group
        [:OnStandard]
      end

      class StandardMetal < Metal
        def self.targets
          [%W[SelectField Material StandardMetal], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class MetalBox < Metal
        def self.targets
          [%W[SelectField Material MetalBox], %W[FieldSet Dimension WidthHeightDepth]]
        end
      end
    end

  end

end

# def self.product_name(subkind, f_name)
#   class_to_cap(f_name.sub('Standard', ''))
# end

# def self.search(subkind, f_name)
#   f_name.sub('Standard', '')
# end
#
# def self.material_attr(subkind, f_name)
#   subkind
# end
