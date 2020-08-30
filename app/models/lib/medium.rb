class Medium
  include Context

  # # tags methods #################### Medium::FSO::OriginalPainting.tags_hsh
  def self.search_tags
    %w[sub_category category medium_category medium material].map{|k| [k, 'n/a']}.to_h
  end

  # FSO ############################# Medium::FSO.tags_hsh

  class FSO < Medium

    class OriginalPainting < FSO
      def self.opt_hsh
        {append_set: AppendSet::Standard.set}
      end

      def self.tags_hsh
        kv_assign(search_tags, [['category', 'Original'], ['medium_category', 'OriginalPainting']])
      end

      class OnPaper < OriginalPainting
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::PaintingOnPaper}
          end
        end
      end

      # class OnCanvas < OriginalPainting
      #   def self.opt_hsh
      #     MaterialSet::OnCanvas.opt_hsh
      #   end
      #
      #   class Media < OnCanvas
      #     def self.opt_hsh
      #       {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::Standard}
      #     end
      #   end
      # end

      class OnStandardMaterial < OriginalPainting
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class Media < OnStandardMaterial
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::StandardPainting}
          end
        end
      end
    end

    #################################

    class OriginalDrawing < FSO
      def self.opt_hsh
        {append_set: AppendSet::Standard.set}
      end

      def self.tags_hsh
        kv_assign(search_tags, [['category', 'Original'], ['medium_category', 'OriginalDrawing']])
      end

      class OnPaper < OriginalDrawing
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Drawing::StandardDrawing}
          end
        end
      end
    end

    #################################

    class OneOfAKindMixedMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'OneOfAKind'], ['medium_category', 'OneOfAKindMixedMedia']])
      end

      class OnPaper < OneOfAKindMixedMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::OnPaper::Embellished, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::BasicMixedMedia, SFO::PrintMedia::MixedMedia::Monotype]}
            end
          end
        end
      end

      class OnCanvas < OneOfAKindMixedMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Standard::Embellished, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia]}
            end
          end
        end
      end
    end

    #################################

    class OneOfAKindAcrylicMixedMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'OneOfAKind'], ['medium_category', 'OneOfAKindMixedMedia']])
      end

      class OnPaper < OneOfAKindAcrylicMixedMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::OneOfAKind, media_set: SFO::PrintMedia::MixedMedia::AcrylicMixedMedia}
          end
        end
      end

      class OnCanvas < OneOfAKindAcrylicMixedMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class Media < OnCanvas
          def self.opt_hsh
            OnPaper::Media.opt_hsh
          end
        end
      end
    end

    #################################

    class OneOfAKindHandPulledMixedMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'OneOfAKind'], ['sub_category', 'HandPulled'], ['medium_category', 'OneOfAKindHandPulledMixedMedia']])
      end

      class OnPaper < OneOfAKindHandPulledMixedMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::OnPaper::Embellished, Category::OriginalMedia::OneOfAKind], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end

      class OnCanvas < OneOfAKindHandPulledMixedMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            OneOfAKindMixedMedia::OnCanvas::SubMedia.opt_hsh
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end
    end

    #################################

    class LimitedEditionPrintMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'LimitedEdition'], ['medium_category', 'LimitedEditionPrintMedia']])
      end

      class OnPaper < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::OnPaper::Embellished, Category::LimitedEdition], append_set: AppendSet::WithSubMediaAndNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnPaper::SubMedia::Media.opt_hsh
            end
          end
        end
      end

      class OnCanvas < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Standard::Embellished, Category::LimitedEdition], append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnCanvas::SubMedia::Media.opt_hsh
            end
          end
        end
      end

      class OnStandardMaterial < LimitedEditionPrintMedia
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            LimitedEditionPrintMedia::OnCanvas::SubMedia.opt_hsh
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnStandardMaterial::SubMedia::Media.opt_hsh
            end
          end
        end
      end
    end

    #################################

    class LimitedEditionHandPulledPrintMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'LimitedEdition'], ['sub_category', 'HandPulled'], ['medium_category', 'LimitedEditionHandPulledPrintMedia']])
      end

      class OnPaper < LimitedEditionHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::OnPaper::Embellished, Category::LimitedEdition, SubMedium::RBF::HandPulled], append_set: AppendSet::WithSubMediaAndNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching]}
            end
          end
        end
      end

      class OnCanvas < LimitedEditionHandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::OnPaper::Embellished, append_set: AppendSet::WithNumbering.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen]}
            end
          end
        end
      end
    end

    #################################

    class HandPulledPrintMedia < FSO
      def self.opt_hsh
        {insert_set: [[1, SubMedium::RBF::HandPulled]]}
      end

      def self.tags_hsh
        kv_assign(search_tags, [['category', 'PrintMedia'], ['sub_category', 'HandPulled'], ['medium_category', 'HandPulledPrintMedia']])
      end

      class OnPaper < HandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::OnPaper::Embellished], append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching]}
            end
          end
        end
      end

      class OnCanvas < HandPulledPrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::OnPaper::Embellished, append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end
      end
    end

    #################################

    class PrintMedia < FSO
      def self.tags_hsh
        kv_assign(search_tags, [['category', 'PrintMedia'], ['medium_category', 'PrintMedia']])
      end

      class OnPaper < PrintMedia
        def self.opt_hsh
          MaterialSet::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::OnPaper::Embellished, append_set: AppendSet::WithSubMedia.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::BasicMixedMedia, SFO::PrintMedia::BasicPrintMedia, SFO::PrintMedia::Poster]}
            end
          end
        end
      end

      class OnCanvas < PrintMedia
        def self.opt_hsh
          MaterialSet::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Standard::Embellished}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia], append_set: AppendSet::Standard.set}
            end
          end
        end
      end

      class OnStandardMaterial < PrintMedia
        def self.opt_hsh
          MaterialSet::OnStandardMaterial.opt_hsh
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Standard::Embellished, append_set: AppendSet::Standard.set}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::BasicMixedMedia]}
            end
          end
        end
      end
    end

  end

  # END FSO #########################

  # SFO #############################

  class SFO < Medium
    def self.builder
      select_field(field_name, field_kind, options, tags)
    end

    def self.field_name
      decamelize(klass_name).pluralize
    end

    def self.tags
      {'title'=> 'n/a', 'description'=> 'n/a'}
    end

    class Painting < SFO
      class StandardPainting < Painting
        def self.options
          Option.builder(['oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end

        def self.field_name
          'paint media'
        end
      end

      class PaintingOnPaper < Painting
        def self.options
          Option.builder(['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end

        def self.field_name
          'paint media (o/p)'
        end
      end
    end

    class Drawing < SFO
      class StandardDrawing < Drawing
        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], field_kind, tags)
        end

        def self.field_name
          'drawing media'
        end
      end
    end

    class PrintMedia < SFO
      class Silkscreen < PrintMedia
        def self.options
          Option.builder(['serigraph', 'silkscreen'], field_kind, tags)
        end
      end

      class Giclee < PrintMedia
        def self.options
          Option.builder(['giclee', 'textured giclee'], field_kind, tags)
        end
      end

      class Lithograph < PrintMedia
        def self.options
          Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], field_kind, tags)
        end
      end

      class Etching < PrintMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], field_kind, tags)
        end
      end

      class Relief < PrintMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'], field_kind, tags)
        end
      end

      class MixedMedia < PrintMedia
        class BasicMixedMedia < MixedMedia
          def self.options
            Option.builder(['mixed media'], field_kind, tags)
          end
        end

        class Monotype < MixedMedia
          def self.options
            Option.builder(['monotype'], field_kind, tags)
          end
        end

        class AcrylicMixedMedia < MixedMedia
          def self.options
            Option.builder(['acrylic mixed media'], field_kind, tags)
          end
        end
      end

      class BasicPrintMedia < PrintMedia
        def self.options
          Option.builder(['print', 'fine art print', 'vintage style print'], field_kind, tags)
        end
      end

      class Poster < PrintMedia
        def self.options
          Option.builder(['poster', 'vintage poster', 'concert poster'], field_kind, tags)
        end
      end

    end

    class PhotographMedia < SFO
      class SportsPhotograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'archival sports photograph'], field_kind, tags)
        end
      end

      class ConcertPhotograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'concert photograph', 'archival concert photograph'], field_kind, tags)
        end
      end

      class Photograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'photolithograph', 'archival photograph'], field_kind, tags)
        end
      end

      class SingleExposurePhotograph < PhotographMedia
        def self.options
          Option.builder(['single exposure photograph'], field_kind, tags)
        end
      end

      class PressPhotograph < PhotographMedia
        def self.options
          Option.builder(['vintage press photograph'], field_kind, tags)
        end
      end
    end

    class SericelMedia < SFO
      class Sericel < SericelMedia
        def self.options
          Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], field_kind, tags)
        end
      end

      class AnimationCel < SericelMedia
        def self.options
          Option.builder(['production cel', 'production cel and matching drawing', 'production cel and two matching drawings', 'production cel and three matching drawings'], field_kind, tags)
        end
      end
    end
  end

  module MaterialSet
    module OnPaper
      def self.opt_hsh
        {material_set: Material::Paper}
      end
    end

    module OnCanvas
      def self.opt_hsh
        {material_set: [Material::Canvas, Material::WrappedCanvas]}
      end
    end

    module OnStandardMaterial
      def self.opt_hsh
        {material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]}
      end
    end
  end

  module AppendSet
    module Standard
      def self.set
        [Authentication::FSO::Standard::SignatureAndCertificate]
      end
    end

    module WithNumbering
      def self.set
        [Numbering, Authentication::FSO::Standard::SignatureAndCertificate]
      end
    end

    module WithSubMedia
      def self.set
        [SubMedium::FSO::OnPaper::LeafingAndRemarque, Authentication::FSO::Standard::SignatureAndCertificate]
      end
    end

    module WithSubMediaAndNumbering
      def self.set
        [SubMedium::FSO::OnPaper::LeafingAndRemarque, Numbering, Authentication::FSO::Standard::SignatureAndCertificate]
      end
    end
  end
end
