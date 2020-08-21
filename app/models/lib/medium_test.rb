class MediumTest
  include Context
  #working draft
  def self.cascade_merge(klass, set, opt_hsh={}) #Prints
    opt_hsh = opt_hsh.merge(klass.opt_hsh) if method_exists?(klass, :opt_hsh)
    return set.append(opt_hsh) if !klass.subclasses.any? #|| !method_exists?(klass, :opt_hsh)
    klass.subclasses.each do |target_class| #OnPaper
      cascade_merge(target_class, set, opt_hsh.merge(target_class.opt_hsh))
    end
  end

  def self.medium_builder(media_set:, material_set:, prepend_set: [], append_set: [], insert_set: [], set: [])
    media_set, material_set, prepend_set, append_set, insert_set = [media_set, material_set, prepend_set, append_set, insert_set].map{|arg| arg_as_arr(arg)}
    media_set.product(material_set).each do |option_set|
      set << option_set_build(options: option_set, prepend_set: prepend_set, append_set: append_set, insert_set: insert_set)
    end
  end

  def self.option_set_build(options:, prepend_set: [], append_set: [], insert_set: [])
    options = prepend_build(options, prepend_set) if prepend_set.any?
    options = append_build(options, append_set) if append_set.any?
    options = insert_build(options, insert_set) if insert_set.any?
    options.flatten
  end

  def self.prepend_build(options, prepend_set)
    prepend_set.reverse.map {|opt| options.prepend(opt)}.flatten
    options
  end

  def self.append_build(options, append_set)
    append_set.map {|opt| options.append(opt)}.flatten if append_set.any?
    options
  end

  def self.insert_build(options, insert_set)
    insert_set.map {|a| options.insert(a[0], a[1])}.flatten if insert_set.any?
    options
  end

  def self.arg_as_arr(arg)
    arg.class == Array ? arg : [arg]
  end

  # MediumTest.option_sets
  def self.option_sets
    set=[]
    FSO.subclasses.each do |klass|
      cascade_merge(klass, set)
    end
    set.map{|h| medium_builder(h)}
  end

  class FSO < MediumTest
    class PrintMedia < FSO
      class OnPaper < PrintMedia
        def self.opt_hsh
          {material_set: Material::Paper}
        end
        # PrintMedia::OnPaper.opt_hsh

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored, append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque]}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Lithograph, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief, SFO::PrintMedia::MixedMedia::Basic, SFO::PrintMedia::Basic, SFO::PrintMedia::Poster]}
            end
          end
        end
      end

      class OnCanvas < PrintMedia
        def self.opt_hsh
          {material_set: [Material::Canvas, Material::WrappedCanvas]}
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Embellished}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::Basic]}
            end
          end
        end
      end

      class OnStandardMaterial < PrintMedia
        def self.opt_hsh
          {material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]}
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Embellished}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::Basic]}
            end
          end

          class LimitedEdition < SubMedia
            def self.opt_hsh
              Media.opt_hsh
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

      class OnPaper < HandPulledPrintMedia
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque]}
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
          PrintMedia::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored}
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

    class LimitedEditionPrintMedia < FSO
      class OnPaper < LimitedEditionPrintMedia
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::LimitedEdition], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque, Numbering]}
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
          PrintMedia::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Embellished, Category::LimitedEdition], append_set: [Numbering]}
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
          PrintMedia::OnStandardMaterial.opt_hsh
          #{material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic]}
        end

        class SubMedia < OnStandardMaterial
          def self.opt_hsh
            LimitedEditionPrintMedia::OnCanvas::SubMedia.opt_hsh
            #{prepend_set: SubMedium::SFO::Embellishment::Embellished}
          end

          class Media < SubMedia
            def self.opt_hsh
              PrintMedia::OnStandardMaterial::SubMedia::Media.opt_hsh
              #{media_set: [SFO::PrintMedia::Giclee, SFO::PrintMedia::Silkscreen, SFO::PrintMedia::MixedMedia::Basic]}
            end
          end
        end
      end
    end

    #################################

    class LimitedEditionHandPulledPrintMedia < FSO
      class OnPaper < LimitedEditionHandPulledPrintMedia
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::LimitedEdition, SubMedium::RBF::HandPulled], append_set: [SubMedium::SMO::Leafing, SubMedium::SFO::Remarque, Numbering]}
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
          PrintMedia::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: SubMedium::SFO::Embellishment::Colored}
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

    class OneOfAKindPrintMedia < FSO
      class OnPaper < OneOfAKindPrintMedia
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class SubMedia < OnPaper
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Colored, Category::OriginalMedia::OneOfAKind], append_set: [SubMedium::SMO::Leafing]}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: [SFO::PrintMedia::Silkscreen, SFO::PrintMedia::Etching, SFO::PrintMedia::Relief]}
            end
          end
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::OneOfAKind, media_set: [SFO::PrintMedia::MixedMedia::Basic, SFO::PrintMedia::MixedMedia::Standard]}
          end
        end
      end

      class OnCanvas < OneOfAKindPrintMedia
        def self.opt_hsh
          PrintMedia::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            {prepend_set: [SubMedium::SFO::Embellishment::Embellished, Category::OriginalMedia::OneOfAKind]}
          end

          class Media < SubMedia
            def self.opt_hsh
              {media_set: SFO::PrintMedia::Silkscreen}
            end
          end
        end

        class Media < OnPaper
          def self.opt_hsh
            OnPaper::Media.opt_hsh
          end
        end
      end
    end

    #################################

    class OneOfAKindHandPulledPrintMedia < FSO
      class OnCanvas < OneOfAKindHandPulledPrintMedia
        def self.opt_hsh
          PrintMedia::OnCanvas.opt_hsh
        end

        class SubMedia < OnCanvas
          def self.opt_hsh
            OneOfAKindPrintMedia::OnCanvas::SubMedia.opt_hsh
          end

          class Media < SubMedia
            def self.opt_hsh
              OneOfAKindPrintMedia::OnCanvas::SubMedia::Media.opt_hsh
            end
          end
        end
      end
    end

    #################################

    class Painting < FSO
      class OnPaper < Painting
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::OnPaper}
          end
        end
      end

      class OnCanvas < Painting
        def self.opt_hsh
          PrintMedia::OnCanvas.opt_hsh
        end

        class Media < OnCanvas
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Painting::Standard}
          end
        end
      end

      class OnStandardMaterial < Painting
        def self.opt_hsh
          PrintMedia::OnStandardMaterial.opt_hsh
        end

        class Media < OnStandardMaterial
          def self.opt_hsh
            OnCanvas::Media.opt_hsh
          end
        end
      end
    end

    #################################

    class Drawing < FSO
      class OnPaper < Drawing
        def self.opt_hsh
          PrintMedia::OnPaper.opt_hsh
        end

        class Media < OnPaper
          def self.opt_hsh
            {prepend_set: Category::OriginalMedia::Original, media_set: SFO::Drawing::Standard}
          end
        end
      end
    end
  end

  #################################

  #################################

  class SFO < MediumTest

    class Painting < SFO
      class Standard < Painting
        def self.options
          Option.builder(['oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end
      end

      class OnPaper < Painting
        def self.options
          Option.builder(['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting'], field_kind, tags)
        end
      end
    end

    class Drawing < SFO
      class Standard < Drawing
        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], field_kind, tags)
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
        class Basic < MixedMedia
          def self.options
            Option.builder(['mixed media'], field_kind, tags)
          end
        end

        class Standard < MixedMedia
          def self.options
            Option.builder(['mixed media acrylic', 'monotype'], field_kind, tags)
          end
        end
      end

      class Basic < PrintMedia
        def self.options
          Option.builder(['print', 'fine art print', 'vintage style print'], field_kind, tags)
        end
      end

      class Poster < PrintMedia
        def self.options
          Option.builder(['poster', 'vintage poster', 'concert poster'], field_kind, tags)
        end
      end

      class Sericel < PrintMedia
        def self.options
          Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], field_kind, tags)
        end
      end
    end

    class PhotographMedia < SFO
      class SportsPhotograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'archival sports photograph'], field_kind, tags)
        end
      end

      class ConsertPhotograph < PhotographMedia
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
    end
  end
end
