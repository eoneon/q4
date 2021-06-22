class StandardFlatArt
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  class Medium < StandardFlatArt
    def self.attrs
      {kind: 1, type: 2, subkind: 3, f_name: -1}
    end

    def self.admin_attrs(args)
      {medium: name_from_class(args[:f_name], [], [['Standard', ''], ['Painting', ''], ['Production','']])}
    end

    def self.name_values(args)
      {medium_search: args[:subkind], product_name: class_to_cap(args[:f_name].sub('Standard', ''))}
    end

    class SelectField < Medium
      def self.origin
        [:StandardAuthentication, :IsDisclaimer]
      end

      class Painting < SelectField #3
        def self.origin
          [:IsOriginal]
        end

        class OnStandard < Painting
          def self.origin
            [:OnStandard]
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
          def self.origin
            [:OnPaper]
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

      class Drawing < SelectField #3
        def self.admin_attrs(args)
          {medium: (args[:f_name].index('Pencil') ? 'Pencil' : 'Pen and Ink')}
        end

        def self.origin
          [:IsOriginal, :OnPaper]
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

        class MixedMediaDrawing < Drawing
          def self.origin
            [:OriginalPaperSubmedia]
          end

          class MixedMediaPencilDrawing < MixedMediaDrawing
            def self.targets
              ['pencil drawing', 'colored pencil drawing']
            end
          end

          class MixedMediaPenAndInkDrawing < MixedMediaDrawing
            def self.targets
              ['pen and ink drawing']
            end
          end
        end
      end

      class Serigraph < SelectField
        def self.origin
          [:IsLimitedEditionOrUniqueVariationOrReproduction, :IsOneOfAKindOrOneOfAKindOfOne]
        end

        class OnStandard < Serigraph
          def self.origin
            [:OnStandard]
          end

          class StandardSerigraph < OnStandard
            def self.targets
              ['serigraph', 'original serigraph', 'silkscreen']
            end
          end
        end

        class OnPaperOrCanvas < Serigraph
          def self.origin
            [:OnPaperOrCanvas]
          end

          class HandPulledSerigraph < OnPaperOrCanvas
            def self.targets
              ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen']
            end
          end
        end
      end

      class Lithograph < SelectField
        def self.origin
          [:IsLimitedEditionOrReproduction, :OnPaper]
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
        class OnStandard < Giclee
          def self.origin
            [:IsLimitedEditionOrReproduction, :OnStandard]
          end

          class StandardGiclee < OnStandard
            def self.targets
              ['giclee', 'textured giclee']
            end
          end
        end
      end

      class Etching < SelectField
        class OnPaper < Etching
          def self.origin
            [:IsLimitedEditionOrReproduction, :IsOneOfAKindOrOneOfAKindOfOne, :OnPaper]
          end

          class StandardEtching < OnPaper
            def self.targets
              ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
            end
          end
        end
      end

      class Relief < SelectField
        def self.admin_attrs
          {medium: 'Mixed Media'}
        end

        def self.origin
          [:IsLimitedEditionOrReproduction, :IsOneOfAKindOrOneOfAKindOfOne, :OnPaper]
        end

        class StandardRelief < Relief
          def self.targets
            ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print']
          end
        end
      end

      class MixedMedia < SelectField
        class OnStandard < MixedMedia
          def self.origin
            [:IsLimitedEditionOrReproduction, :IsOneOfAKindOrOneOfAKindOfOne, :OnStandard]
          end

          class StandardMixedMedia < OnStandard
            def self.targets
              ['mixed media']
            end
          end
        end

        class OnPaperOrCanvas < Serigraph
          def self.origin
            [:IsLimitedEditionOrReproduction, :IsOneOfAKindOrOneOfAKindOfOne, :OnPaperOrCanvas]
          end

          class AcrylicMixedMedia < OnPaperOrCanvas
            def self.targets
              ['acrylic mixed media']
            end
          end
        end

        class OnPaper < MixedMedia
          def self.origin
            [:OnPaper]
          end

          class Monotype < OnPaper
            def self.origin
              [:IsOneOfAKindOrOneOfAKindOfOne]
            end

            def self.targets
              ['monotype', 'monoprint']
            end
          end

          class Seriolithograph < OnPaper
            def self.origin
              [:IsLimitedEditionOrReproduction]
            end

            def self.targets
              ['seriolithograph']
            end
          end
        end

      end

      class PrintMedia < SelectField
        class OnStandard < PrintMedia
          def self.origin
            [:IsLimitedEditionOrReproduction, :OnStandard]
          end

          class StandardPrint < OnStandard
            def self.targets
              ['print', 'fine art print', 'vintage style print']
            end
          end
        end
      end

      class Poster < SelectField
        def self.origin
          [:IsReproduction, :OnPaper]
        end

        class StandardPoster < Poster
          def self.targets
            ['poster', 'vintage poster', 'concert poster']
          end
        end
      end

      class Photograph < SelectField
        def self.origin
          [:IsLimitedEditionOrReproduction, :OnPhotoPaper]
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
          def self.origin
            [:IsLimitedEditionOrReproduction]
          end

          def self.targets
            ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
          end
        end
      end

      class ProductionArt < SelectField
        def self.origin
          [:IsOriginal]
        end

        class ProductionCel < ProductionArt
          def self.targets
            ['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings']
          end
        end

        class OnAnimationPaper < ProductionArt
          def self.origin
            [:OnAnimationPaper]
          end

          class ProductionDrawing < OnAnimationPaper
            def self.targets
              ['production drawing', 'production drawing set']
            end
          end
        end
      end

    end
  end
end
