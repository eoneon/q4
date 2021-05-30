class Medium
  include ClassContext
  include FieldSeed
  include Hashable

  def self.builder(store)
    args = build_attrs(:attrs)
    add_field_group(to_class(args[:type]), self, args[:type], args[:kind], args[:f_name], store, build_tags(args, :product_name, :search, :subsearch, :medium_attr))
  end

  def self.attrs
    {kind: 0, type: 1, f_name: -1}
  end

  ##############################################################################

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

  ##############################################################################

  class SelectField < Medium

    def self.assoc_group
      kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
      desc_select_then_asc_detect(:targets, :assocs).each_with_object({}) do |(k,v), assocs|
        case_merge(assocs, k, v, kind, type)
      end
    end

    # def self.assoc_group
    #   kind, type = [:kind,:type].map{|k| build_attrs(:attrs)[k].to_sym}
    #   merge_enum(:targets, :group).each_with_object({}) do |(k,v), assocs|
    #     case_merge(assocs, k, v, kind, type)
    #   end
    # end

    class Painting < SelectField
      def self.attrs
        {subkind: 2}
      end

      def self.medium_attr(args)
        args[:f_name].sub('Painting','')
      end

      def self.assocs
        {Category: {RadioButton: :IsOriginal}}
      end

      class OnStandard < Painting
        def self.assocs
          {Material: {FieldSet: :OnStandard}}
        end

        class OilPainting < OnStandard
          def self.targets
            ['oil painting', 'mixed media oil painting']
          end
        end

        class AcylicPainting < OnStandard
          def self.targets
            ['acrylic painting', 'mixed media painting']
          end
        end

        class MixedMediaPainting < OnStandard
          def self.targets
            ['mixed media painting', 'overpaint', 'oil and acrylic painting']
          end
        end

        class UnknownPainting < OnStandard
          def self.targets
            ['painting']
          end
        end
      end

      class OnPaper < Painting
        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class WatercolorPainting < OnPaper
          def self.targets
            ['watercolor painting', 'sumi ink painting']
          end
        end

        class PastelPainting < OnPaper
          def self.targets
            ['pastel painting']
          end
        end

        class GuachePainting < OnPaper
          def self.targets
            ['guache painting']
          end
        end
      end

    end

    class Drawing < SelectField
      def self.attrs
        {subkind: 2}
      end

      def self.medium_attr(args)
        args[:f_name].index('Pencil') ? 'Pencil' : 'Pen and Ink'
      end

      def self.assocs
        {Category: {RadioButton: :IsOriginal}}
      end

      class OnPaper < Drawing

        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class PencilDrawing < OnPaper
          def self.targets
            ['pencil drawing', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
          end
        end

        class PenAndInkDrawing < OnPaper
          def self.targets
            ['pen and ink drawing', 'pen and ink study']
          end
        end

        class MixedMediaPencilDrawing < OnPaper
          def self.targets
            ['pencil drawing', 'colored pencil drawing']
          end
        end

        class MixedMediaPenAndInkDrawing < OnPaper
          def self.targets
            ['pen and ink drawing']
          end
        end
      end
    end

    class Serigraph < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnStandard < Serigraph
        def self.assocs
          {Material: {FieldSet: :OnStandard}}
        end

        class StandardSerigraph < OnStandard
          def self.targets
            ['serigraph', 'original serigraph', 'silkscreen']
          end
        end
      end

      class OnPaperOrCanvas < Serigraph
        def self.assocs
          {Material: {FieldSet: :OnPaperOrCanvas}}
        end

        class HandPulledSerigraph < OnPaperOrCanvas
          def self.targets
            ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen']
          end
        end
      end
    end

    class Lithograph < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnPaper < Lithograph
        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class StandardLithograph < OnPaper
          def self.targets
            ['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph', 'hand pulled original lithograph']
          end
        end

        class HandPulledLithograph < OnPaper
          def self.targets
            ['hand pulled lithograph', 'hand pulled original lithograph']
          end
        end
      end
    end

    class Giclee < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnStandard < Giclee
        def self.assocs
          {Material: {FieldSet: :OnStandard}}
        end

        class StandardGiclee < OnStandard
          def self.targets
            ['giclee', 'textured giclee']
          end
        end
      end
    end

    class Etching < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnPaper < Etching
        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class StandardEtching < OnPaper
          def self.targets
            ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
          end
        end
      end
    end

    class Relief < SelectField
      def self.attrs
        {subkind: 2}
      end

      def self.medium_attr(args)
        'Mixed Media'
      end

      class OnPaper < Relief
        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class StandardRelief < OnPaper
          def self.targets
            ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
          end
        end
      end
    end

    class MixedMedia < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnStandard < MixedMedia
        def self.assocs
          {Material: {FieldSet: :OnStandard}}
        end

        class StandardMixedMedia < OnStandard
          def self.targets
            ['mixed media']
          end
        end
      end

      class OnPaperOrCanvas < Serigraph
        class AcrylicMixedMedia < OnPaperOrCanvas
          def self.targets
            ['acrylic mixed media']
          end
        end
      end

      class OnPaper < MixedMedia
        class Monotype < OnPaper
          def self.targets
            ['monotype', 'monoprint']
          end
        end

        class Seriolithograph < OnPaper
          def self.targets
            ['seriolithograph']
          end
        end
      end

    end

    class PrintMedia < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnStandard < PrintMedia
        def self.assocs
          {Material: {FieldSet: :OnStandard}}
        end

        class StandardPrint < OnStandard
          def self.targets
            ['print', 'fine art print', 'vintage style print']
          end
        end
      end
    end

    class Poster < SelectField
      def self.attrs
        {subkind: -2}
      end

      class OnPaper < Poster
        def self.assocs
          {Material: {FieldSet: :OnPaper}}
        end

        class StandardPoster < OnPaper
          def self.targets
            ['poster', 'vintage poster', 'concert poster']
          end
        end
      end
    end

    class Photograph < SelectField
      def self.attrs
        {subkind: 2}
      end

      class OnPhotoPaper < Photograph
        def self.assocs
          {Material: {FieldSet: :OnPhotoPaper}}
        end

        class StandardPhotograph < OnPhotoPaper
          def self.targets
            ['photograph']
          end
        end

        class SingleExposurePhotograph < OnPhotoPaper
          def self.targets
            ['single exposure photograph']
          end
        end

        class SportsPhotograph < OnPhotoPaper
          def self.targets
            ['photograph', 'archival sports photograph']
          end
        end

        class ConcertPhotograph < OnPhotoPaper
          def self.targets
            ['photograph', 'concert photograph', 'archival concert photograph']
          end
        end

        class PressPhotograph < OnPhotoPaper
          def self.targets
            ['vintage press photograph']
          end
        end
      end
    end

    class Sericel < SelectField
      def self.attrs
        {subkind: 2}
      end

      class StandardSericel < Sericel
        def self.targets
          ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
        end
      end

    end

    class ProductionArt < SelectField
      def self.attrs
        {subkind: 2}
      end

      class ProductionCel < ProductionArt
        def self.targets
          ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
        end
      end

      class OnAnimationPaper < ProductionArt
        def self.assocs
          {Material: {FieldSet: :OnAnimationPaper}}
        end

        class ProductionDrawing < OnAnimationPaper
          def self.targets
            ['production drawing', 'production drawing set']
          end
        end
      end
    end

    class Sculpture < SelectField
      def self.attrs
        {subkind: 2}
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
