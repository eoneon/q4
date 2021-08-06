class Material
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 0, type: 1, subkind: 2, f_name: -1}
  end

  def self.input_group
    [2, %w[material mounting]]
  end

  class SelectField < Material
    def self.target_tags(f_name)
      {tagline: "on #{tagline(f_name)}", body: "on #{body(f_name)}", material_mounting: ('This piece comes gallery wrapped' if f_name.index('gallery'))}
    end

    def self.tagline(f_name)
      str_edit(str: f_name, swap: ['stretched', ''])
    end

    def self.body(f_name)
      swap_str(f_name, ['gallery wrapped', ''])
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
    def self.admin_attrs(args)
      {material: args[:subkind]}
    end

    def self.name_values(args)
      {material_search: args[:subkind], product_name: "on #{str_edit(str: uncamel(args[:f_name]), swap: ['Standard', ''])}"}
    end

    class Canvas < FieldSet
      class StandardCanvas < Canvas
        def self.targets
          [%W[SelectField Material StandardCanvas], %W[FieldSet Dimension WidthHeight], %W[SelectMenu Mounting CanvasMounting]]
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
        def self.targets
          [%W[SelectField Material StandardPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class PhotoPaper < Paper
        def self.name_values(args)
          {product_name: ""}
        end

        def self.targets
          [%W[SelectField Material PhotoPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end

      class AnimationPaper < Paper
        def self.name_values(args)
          {product_name: ""}
        end

        def self.targets
          [%W[SelectField Material AnimationPaper], %W[SelectMenu Dimension FlatDimension], %W[SelectMenu Mounting StandardMounting]]
        end
      end
    end

    class Board < FieldSet
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
