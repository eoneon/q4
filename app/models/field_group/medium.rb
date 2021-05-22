class Medium
  include ClassContext
  include FieldSeed

  def self.cascade_build(store)
    #f_kind, f_type, subkind, f_name = f_attrs(0, 1, 2, 3)
    #f_kind, f_type, subkind, f_name = f_attrs(class_tree, :kind, :type, :subkind).merge({f_name: const}) #(0, 1, 2, 3)
    #f_kind, f_type, subkind, f_name = f_attrs(class_tree, :kind, :type, :subkind, :f_name).values #.merge({f_name: const})
    #tags = build_tags(args: {subkind: subkind, f_name: f_name}, tag_set: tag_set, class_set: class_tree)
    args = collect_params(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store, build_tags(args, :product_name, :search, :subsearch, :medium_attr))
  end

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  ##############################################################################
  def self.tag_methods
    [:product_name, :search, :subsearch, :medium_attr]
  end

  def self.product_name(args)
    class_to_cap(args[:f_name].sub('Standard', ''), %w[and])
  end

  def self.search(args)
    args[:subkind]
  end

  def self.subsearch(args)
    args[:f_name].sub('Standard', '')
  end

  def self.medium_attr(args)
    args[:f_name]
  end


  class SelectField < Medium

    class Painting < SelectField

      def self.attrs
        {subkind: -2}
      end

      def self.medium_attr(args)
        args[:f_name].sub('Painting','')
      end

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

      class WatercolorPainting < Painting
        def self.targets
          ['watercolor painting', 'sumi ink painting']
        end
      end

      class PastelPainting < Painting
        def self.targets
          ['pastel painting']
        end
      end

      class GuachePainting < Painting
        def self.targets
          ['guache painting']
        end
      end

    end

    class Drawing < SelectField

      def self.attrs
        {subkind: -2}
      end

      def self.medium_attr(args)
        args[:f_name].index('Pencil') ? 'Pencil' : 'Pen and Ink'
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
      def self.attrs
        {subkind: -2}
      end

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

    class Lithograph < SelectField
      def self.attrs
        {subkind: -2}
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

    class Giclee < SelectField
      def self.attrs
        {subkind: -2}
      end

      class StandardGiclee < Giclee
        def self.targets
          ['giclee', 'textured giclee']
        end
      end
    end

    class Etching < SelectField
      def self.attrs
        {subkind: -2}
      end

      class StandardEtching < Etching
        def self.targets
          ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
        end
      end
    end

    class Relief < SelectField
      def self.attrs
        {subkind: -2}
      end

      def self.medium_attr(args)
        'Mixed Media'
      end

      class StandardRelief < Relief
        def self.targets
          ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
        end
      end
    end

    class MixedMedia < SelectField
      def self.attrs
        {subkind: -2}
      end
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

      class Monotype < MixedMedia
        def self.targets
          ['monotype', 'monoprint']
        end
      end

      class Seriolithograph < MixedMedia
        def self.targets
          ['seriolithograph']
        end
      end
    end

    class PrintMedia < SelectField
      def self.attrs
        {subkind: -2}
      end

      class StandardPrint < PrintMedia
        def self.targets
          ['print', 'fine art print', 'vintage style print']
        end
      end
    end

    class Poster < SelectField
      def self.attrs
        {subkind: -2}
      end

      class StandardPoster < Poster
        def self.targets
          ['poster', 'vintage poster', 'concert poster']
        end
      end
    end

    class Photograph < SelectField
      def self.attrs
        {subkind: -2}
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
      def self.attrs
        {subkind: -2}
      end
      class StandardSericel < Sericel
        def self.targets
          ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
        end
      end
    end

    class ProductionArt < SelectField
      def self.attrs
        {subkind: -2}
      end

      class ProductionCel < ProductionArt
        def self.targets
          ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
        end
      end

      class ProductionDrawing < ProductionArt
        def self.targets
          ['production drawing', 'production drawing set']
        end
      end
    end

    class Sculpture < SelectField
      def self.attrs
        {subkind: -2}
      end

      class StandardSculpture < Sculpture
        def self.targets
          ['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'resin', 'pewter', 'mixed media']
        end
      end

      class HandBlownGlass < Sculpture
        def self.targets
          ['hand blown glass']
        end
      end

      class GartnerBladeGlass < Sculpture
        def self.targets
          ['hand blown glass']
        end
      end
    end
  end
end
