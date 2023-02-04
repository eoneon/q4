class Material
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 0, type: 1, subkind: 2, field_name: -1}
  end

  def self.input_group
    [2, %w[material mounting]]
  end

  def self.merge_related_params(input_group, f, args)
  	if v = f.tags[args[1]]
  		Item.case_merge(input_group[:d_hsh], v, *args)
  		f.set_order(input_group[:context], args[-1].to_sym, args[0])
  		Mounting.mounting_search_params(input_group[:d_hsh], f.tags, args[0])
  	end
  end

  class SelectField < Material
    def self.target_tags(f_name)
      {tagline: "on #{tagline(f_name)}", body: "on #{body(f_name)}", invoice_tagline: "on #{str_edit(str: f_name)}", tagline_search: "on #{tagline_search(f_name)}", material_mounting: ('This piece comes gallery wrapped.' if f_name.index('gallery'))}
    end

    def self.tagline(f_name)
      str_edit(str: f_name, swap: ['stretched', ''])
    end

    def self.body(f_name)
      swap_str(f_name, ['gallery wrapped', ''])
    end

    def self.tagline_search(f_name)
      str_edit(str: f_name, swap: ['stretched', '', 'gallery wrapped', ''])
    end

    class Canvas < SelectField
      class StandardCanvas < Canvas
        def self.targets
          ['canvas', 'canvas board', 'textured canvas']
        end
      end

      class WrappedCanvas < Canvas
        def self.target_tags(f_name)
          {mounting_search: (f_name.index('stretched') ? 'Stretched' : 'Gallery Wrapped')}
        end

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
    class FlatType < FieldSet
      def self.attrs
        {subkind: 3}
      end

      def self.admin_attrs(args)
        {material: args[:subkind]}
      end

      def self.name_values(args)
        {material_search: args[:subkind], product_name: "on #{str_edit(str: uncamel(args[:field_name]), swap: ['Standard', ''])}"}
      end

      class Canvas < FlatType
        class StandardCanvas < Canvas
          def self.targets
            [%W[SelectField Material StandardCanvas], %W[SelectMenu Dimension CanvasDimension], %W[SelectMenu Mounting CanvasMounting]]
          end
        end

        class WrappedCanvas < Canvas
          def self.targets
            [%W[SelectField Material WrappedCanvas], %W[SelectMenu Dimension CanvasDimension]]
          end
        end
      end

      class Paper < FlatType
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

      class Board < FlatType
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

      class Metal < FlatType
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

      class Sericel < FlatType
        class StandardSericel < Sericel
          def self.name_values(args)
            {product_name: ""}
          end

          def self.targets
            [%W[FieldSet Dimension WidthHeight], %W[SelectMenu Mounting CanvasMounting]]
          end
        end
      end
    end

    class DepthType < FieldSet
      class DiameterType < DepthType
        def self.targets
          [%W[FieldSet Dimension DiameterWeight]]
        end
      end

      class DiameterHeightType < DepthType
        def self.targets
          [%W[FieldSet Dimension DiameterHeightWeight]]
        end
      end

      class WidthHeightDepthType < DepthType
        def self.targets
          [%W[FieldSet Dimension WidthHeightDepthWeight]]
        end
      end

    end
  end

end
