class Medium
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.attrs
    {kind: 0, type: 1, subkind: 2, f_name: -1}
  end

  def self.admin_attrs(args)
    {medium: str_edit(str: uncamel(args[:f_name]), swap: ['Standard', '', 'Painting', '', 'Production','', 'Sculpture', '', 'Hand Made', ''])}
  end

  def self.name_values(args)
    {medium_search: args[:subkind], product_name: str_edit(str: uncamel(args[:f_name]), swap: ['Standard', '', 'Sculpture', '', 'Unknown', '', ' And ', ' and '], skip:['and']), origin: args[:f_name]}
  end

  def self.input_group
    [0, %w[medium embellishing leafing remarque]]
  end

  class SelectField < Medium
    def self.target_tags(f_name)
      {tagline: str_edit(str: f_name, skip:['and', 'on']), body: f_name}
    end

    class Painting < SelectField
      class OilPainting < Painting
        def self.targets
          ['oil painting', 'mixed media oil painting']
        end
      end

      class AcylicPainting < Painting
        def self.targets
          ['acrylic painting', 'mixed media painting']
        end
      end

      class MixedMediaPainting < Painting
        def self.targets
          ['mixed media painting', 'overpaint', 'oil and acrylic painting']
        end
      end

      class UnknownPainting < Painting
        def self.targets
          ['painting']
        end
      end

      class PaperOnly < Painting
        def self.admin_attrs
          {paper_only: 'paper_only'}
        end

        class WatercolorPainting < PaperOnly
          def self.targets
            ['watercolor painting', 'sumi ink painting']
          end
        end

        class PastelPainting < PaperOnly
          def self.targets
            ['pastel painting']
          end
        end

        class GuachePainting < PaperOnly
          def self.targets
            ['guache painting']
          end
        end
      end
    end

    class Drawing < SelectField
      def self.admin_attrs(args)
        {medium: (args[:f_name].index('Pencil') ? 'Pencil' : 'Pen and Ink'), paper_only: 'paper_only'}
      end

      class PencilDrawing < Drawing
        def self.targets
          ['pencil drawing', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
        end
      end

      class PenAndInkDrawing < Drawing
        def self.targets
          ['pen and ink drawing', 'pen and ink study']
        end
      end

      class MixedMediaPencilDrawing < Drawing
        def self.targets
          ['pencil drawing', 'colored pencil drawing']
        end
      end

      class MixedMediaPenAndInkDrawing < Drawing
        def self.targets
          ['pen and ink drawing']
        end
      end
    end

    class Serigraph < SelectField
      class StandardSerigraph < Serigraph
        def self.targets
          ['serigraph', 'original serigraph', 'silkscreen']
        end
      end

      class HandPulledSerigraph < Serigraph
        def self.targets
          ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen']
        end
      end
    end

    class Giclee < SelectField
      class StandardGiclee < Giclee
        def self.targets
          ['giclee', 'textured giclee']
        end
      end
    end

    class Lithograph < SelectField
      def self.admin_attrs
        {paper_only: 'paper_only'}
      end

      class StandardLithograph < Lithograph
        def self.targets
          ['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph', 'hand pulled original lithograph']
        end
      end

      class HandPulledLithograph < Lithograph
        def self.targets
          ['hand pulled lithograph', 'hand pulled original lithograph']
        end
      end
    end

    class Etching < SelectField
      def self.admin_attrs
        {paper_only: 'paper_only'}
      end

      class StandardEtching < Etching
        def self.targets
          ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
        end
      end
    end

    class Relief < SelectField
      def self.admin_attrs
        {medium: 'Mixed Media', paper_only: 'paper_only'}
      end

      class StandardRelief < Relief
        def self.targets
          ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
        end
      end
    end

    class MixedMedia < SelectField
      class StandardMixedMedia < MixedMedia
        def self.targets
          ['mixed media']
        end
      end

      class AcrylicMixedMedia < MixedMedia
        def self.targets
          ['acrylic mixed media']
        end
      end

      class PaperOnly < MixedMedia
        def self.admin_attrs
          {paper_only: 'paper_only'}
        end

        class Monotype < PaperOnly
          def self.targets
            ['monotype', 'monoprint']
          end
        end

        class Seriolithograph < PaperOnly
          def self.targets
            ['seriolithograph']
          end
        end
      end
    end

    class PrintMedia < SelectField
      class StandardPrint < PrintMedia
        def self.targets
          ['print', 'fine art print', 'vintage style print']
        end
      end

      class Poster < PrintMedia
        def self.admin_attrs
          {paper_only: 'paper_only'}
        end

        def self.targets
          ['poster', 'vintage poster', 'concert poster']
        end
      end
    end

    class Photograph < SelectField
      def self.admin_attrs
        {paper_only: 'paper_only'}
      end

      class StandardPhotograph < Photograph
        def self.targets
          ['photograph']
        end
      end

      class SingleExposurePhotograph < Photograph
        def self.targets
          ['single exposure photograph']
        end
      end

      class SportsPhotograph < Photograph
        def self.targets
          ['photograph', 'archival sports photograph']
        end
      end

      class ConcertPhotograph < Photograph
        def self.targets
          ['photograph', 'concert photograph', 'archival concert photograph']
        end
      end

      class PressPhotograph < Photograph
        def self.targets
          ['vintage press photograph']
        end
      end
    end

    class Sericel < SelectField
      class StandardSericel < Sericel
        def self.targets
          ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
        end
      end
    end

    class ProductionArt < SelectField
      class ProductionCel < ProductionArt
        def self.targets
          ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
        end
      end

      class ProductionDrawing < ProductionArt
        def self.admin_attrs
          {paper_only: 'paper_only'}
        end

        def self.targets
          ['production drawing', 'production drawing set']
        end
      end
    end

    class StandardSculpture < Medium
      class AcrylicSculpture < StandardSculpture
        def self.targets
          ['acrylic', 'lucite']
        end
      end

      class GlassSculpture < StandardSculpture
        def self.targets
          ['glass']
        end
      end

      class PewterSculpture < StandardSculpture
        def self.targets
          ['pewter', 'mixed media pewter']
        end
      end

      class PorcelainSculpture < StandardSculpture
        def self.targets
          ['porcelain']
        end
      end

      class ResinSculpture < StandardSculpture
        def self.targets
          ['resin', 'mixed media resin']
        end
      end

      class MixedMediaSculpture < StandardSculpture
        def self.targets
          ['mixed media', 'lucite and pewter']
        end
      end
    end

    class HandMadeSculpture < Medium
      class HandMadeCeramic < HandMadeSculpture
        def self.targets
          ['hand made ceramic']
        end
      end

      class HandBlownGlass < HandMadeSculpture
        def self.targets
          ['hand blown glass']
        end
      end
    end

  end
end
