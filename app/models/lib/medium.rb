class Medium
  include Context

  class SFO < Medium
    def self.tags
      tags_hsh(0,-2)
    end

    def self.builder
      select_field(field_class_name, options, tags_hsh(0,-2))
    end

    ############################################################################

    class PaintingMedia < SFO
      class Painting < PaintingMedia
        def self.options
          OptionSet.builder(['painting', 'oil', 'acrylic', 'mixed media'], tags)
        end
      end

      class PaintingOnPaper < PaintingMedia
        def self.options
          OptionSet.builder(['watercolor', 'pastel', 'guache', 'sumi ink'], tags)
        end
      end

      module OptionSet
        def self.builder(set, tags)
          Option.builder(set.map {|opt_name| Medium.build_name([opt_name, 'painting'])}, tags)
        end
      end
    end

    class DrawingMedia < SFO
      class Drawing < DrawingMedia
        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], tags_hsh(0,-2))
        end
      end

      class BasicDrawing < DrawingMedia
        def self.options
          Option.builder(['pen and ink drawing', 'pencil drawing'], tags_hsh(0,1))
        end
      end
    end

    class ProductionMedia < SFO
      class Drawing < ProductionMedia
        def self.options
          Option.builder(['drawing'], tags_hsh(0,-2))
        end
      end

      class Sericel < ProductionMedia
        def self.options
          SericelMedia::BasicSericel.options
        end
      end
    end

    ############################################################################

    class LithographMedia < SFO
      class Lithograph < LithographMedia
        def self.options
          Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], tags_hsh(0,-2))
        end
      end

      class BasicLithograph < LithographMedia
        def self.options
          Option.builder(['lithograph'], tags_hsh(0,1))
        end
      end
    end

    class EtchingMedia < SFO
      class Etching < EtchingMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], tags_hsh(0,-2))
        end
      end

      class BasicEtching < EtchingMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)'], tags_hsh(0,-2))
        end
      end
    end

    class ReliefMedia < SFO
      class Relief < ReliefMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'], tags_hsh(0,-2))
        end
      end

      class BasicRelief < ReliefMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut'], tags_hsh(0,-2))
        end
      end
    end

    class SilkscreenMedia < SFO
      class Serigraph < SilkscreenMedia
        def self.options
          Option.builder(['serigraph'], tags_hsh(0,-2))
        end
      end

      class Silkscreen < SilkscreenMedia
        def self.options
          Option.builder(['silkscreen'], tags_hsh(0,-2))
        end
      end
    end

    class Giclee < SFO
      def self.options
        Option.builder(['giclee'], tags_hsh(0,-2))
      end
    end

    class MixedMedia < SFO
      class BasicMixedMedia < MixedMedia
        def self.options
          Option.builder(['mixed media'], tags_hsh(0,-2))
        end
      end

      class AcrylicMixedMedia < MixedMedia
        def self.options
          Option.builder(['mixed media acrylic'], tags_hsh(0,-2))
        end
      end

      class Monotype < MixedMedia
        def self.options
          Option.builder(['monotype'], tags_hsh(0,-2))
        end
      end
    end

    class PhotoMedia < SFO
      class Photograph < PhotoMedia
        def self.options
          Option.builder(['photograph', 'photolithograph', 'archival photograph'], tags_hsh(0,-2))
        end
      end

      class SingleExposurePhoto < PhotoMedia
        def self.options
          Option.builder(['single exposure photograph'], tags_hsh(0,1))
        end
      end
    end

    class PrintMedia < SFO
      class BasicPrint < PrintMedia
        def self.options
          Option.builder(['print', 'fine art print', 'vintage style print'], tags_hsh(0,-2))
        end
      end

      class Poster < PrintMedia
        def self.options
          Option.builder(['poster', 'vintage poster', 'concert poster'], tags_hsh(0,-2))
        end
      end
    end

    class SericelMedia < SFO
      class Sericel < SericelMedia
        def self.options
          Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], tags_hsh(0,-2))
        end
      end

      class BasicSericel < SericelMedia
        def self.options
          Option.builder(['sericel', 'hand painted sericel'], tags_hsh(0,-2))
        end
      end
    end

  end

  ##############################################################################
  #set = Medium::FSO.builder
  class FSO < Medium
    def self.builder
      [StandardPrint, NumberedPrint::LimitedEdition, NumberedPrint::UniqueVariation, OneOfAKindPrint].each do |option_group|
        option_group.options.each do |option_set|
          field_set(build_name(option_set), build_options(option_set), build_tags(option_set))
        end
      end
    end

    ############################################################################

    def self.build_name(options, name_set=[])
      options.each do |klass|
        kind, name = klass.tags[:kind], decamelize(klass.klass_name)
        name_set << build_name_set(option_names(options), kind, name)
      end
      name_set.join(" ")
    end

    def self.build_name_set(opt_names, kind, name)
      if kind == 'material'
        "on #{name}"
      elsif %w[leafing remarque].include?(kind)
        leafing_and_remarque(opt_names, kind, name)
      elsif name == "one of a kind"
        name.split(" ").join("-")
      elsif kind != 'numbering'
        name
      end
    end

    def self.leafing_and_remarque(opt_names, kind, name)
      if include_all?(%w[leafing remarque], opt_names)
        kind == 'leafing' ? "with #{name}" : "and #{name}"
      else
        "with #{name}"
      end
    end

    ############################################################################

    def self.build_options(options)
      options.map{|klass| klass.builder}.flatten
    end

    ############################################################################

    def self.media_set(*idx_set)
      if idx_set.empty?
        set.map{|a| a[1..-1]}.flatten
      elsif idx_set.count == 1
        set.assoc(idx_set[0])[1..-1]
      elsif idx_set.count > 1
        idx_set.map{|i| set.assoc(i)[1..-1]}.flatten
      end
    end

    def self.option_names(options)
      options.map{|klass| klass.tags[:kind]}
    end

    def self.build_tags(option_set, tags={})
      option_set.each do |klass|
        if klass.tags[:kind] == 'medium'
          tags.merge!(klass.tags)
        else
          tags.merge!(h={:"#{klass.tags[:kind]}" => klass.tags[:sub_kind]})
        end
      end
      tags
    end

    ############################################################################

    #Medium::FSO::StandardPrint.options
    class StandardPrint < FSO
      def self.options
        set=[]
        [OriginalPainting, OriginalPaintingOnPaper, OriginalDrawing, OriginalMixedMediaDrawing, OriginalProductionDrawing, OriginalProductionSericel, MixedPrintOnPaperOnly, MixedPrintOnPaper, MixedPrintOnCanvas, MixedPrintOnStandardMaterial, HandPulledPrintOnPaper, HandPulledPrintOnCanvas, PhotoPrint, SericelPrint].each do |option_group|
          option_group.options.each do |option_set|
            set << option_set
          end
        end
        set
      end
    end
    #Medium::FSO::NumberedPrint::LimitedEdition.options
    class NumberedPrint < FSO
      class LimitedEdition < NumberedPrint
        def self.options
          StandardPrint.options.map {|option_set| insert_build(option_set, Category::LimitedEdition, Numbering)}
        end
      end
      #Medium::FSO::NumberedPrint::UniqueVariation.options
      class UniqueVariation < NumberedPrint
        def self.options
          set=[]
          [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly].each do |option_group|
            option_group.options.each do |option_set|
              set << insert_build(option_set, Category::UniqueVariation, Numbering)
            end
          end
          set
        end
      end
    end
    #Medium::FSO::OneOfAKindPrint.options
    class OneOfAKindPrint < FSO
      def self.options
        set=[]
        [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly, MixedMediaOnPaper].each do |option_group|
          option_group.options.each do |option_set|
            set << prepend_build(option_set, Category::OriginalMedia::OneOfAKind)
          end
        end
        set
      end
    end
    #Medium::FSO::OriginalPainting.options
    class OriginalPainting < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::PaintingMedia::Painting], material_set: Material::StandardMaterial.options, prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalPaintingOnPaper < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::PaintingMedia::PaintingOnPaper], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalDrawing < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::DrawingMedia::Drawing], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalMixedMediaDrawing < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::DrawingMedia::BasicDrawing], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original], append_set: [SubMedium::SMO::Leafing])
      end
    end

    class OriginalProductionDrawing < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::ProductionMedia::Drawing], material_set: [Material::AnimationPaper], prepend_set: [Category::OriginalMedia::OriginalProduction])
      end
    end

    class OriginalProductionSericel < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::ProductionMedia::Sericel], material_set: [Material::Sericel], prepend_set: [Category::OriginalMedia::OriginalProduction])
      end
    end

    class SericelPrint < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::SericelMedia::Sericel], material_set: [Material::Sericel])
      end
    end

    class PhotoPrint < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::PhotoMedia::Photograph, SFO::PhotoMedia::SingleExposurePhoto], material_set: [Material::PhotographyPaper])
      end
    end

    class MixedMediaOnPaper < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::MixedMedia::Monotype, SFO::MixedMedia::AcrylicMixedMedia], material_set: [Material::Paper])
      end
    end

    class PrintOnPaperWithRemarque < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::PrintMedia::Poster], material_set: [Material::Paper], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class PrintOnCanvas < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::MixedMedia::AcrylicMixedMedia], material_set: [Material::Canvas, Material::WrappedCanvas])
      end
    end

    class MixedPrintOnPaperOnly < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::LithographMedia::Lithograph, SFO::EtchingMedia::Etching, SFO::ReliefMedia::Relief], material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class BasicMixedPrintOnPaper < FSO
      def self.options
        FieldSetOption.builder(media_set: [SFO::EtchingMedia::BasicEtching, SFO::ReliefMedia::BasicRelief], material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SFO::Remarque])
      end
    end

    ############################################################################
    # Medium::FSO::MixedPrintOnPaper.media_set
    # Medium::FSO::MixedPrintOnPaper.options
    class MixedPrintOnPaper < FSO
      def self.options
        FieldSetOption.builder(media_set: media_set, material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SFO::Remarque])
      end

      def self.set
        [
          [0,
            SFO::SilkscreenMedia::Serigraph,
            SFO::SilkscreenMedia::Silkscreen
          ],

          [1,
            SFO::Giclee,
            SFO::MixedMedia::BasicMixedMedia,
            SFO::PrintMedia::BasicPrint
          ]
        ]
      end
    end #end of MixedPrintOnPaper

    ############################################################################
    # Medium::FSO::MixedPrintOnPaper.media_set
    # Medium::FSO::MixedPrintOnPaper.options
    class MixedPrintOnCanvas < FSO
      def self.options
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set, material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Colored])
      end
    end

    class MixedPrintOnStandardMaterial < FSO
      def self.options
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set, material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic], prepend_set: [SubMedium::SFO::Embellishment::Embellished], append_set: [SubMedium::SFO::Remarque])
      end
    end #end of MixedPrintOnCanvas

    class HandPulledPrintOnPaper < FSO
      def self.options
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set(0), material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class HandPulledPrintOnCanvas < FSO
      def self.options
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set(0), material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Embellished, SubMedium::RBF::HandPulled])
      end
    end
  end

  module FieldSetOption
    def self.builder(media_set:, material_set:, prepend_set: [], append_set: [], set: [])
      media_set, material_set, prepend_set, append_set = [media_set, material_set, prepend_set, append_set].map{|arg| Medium.arg_as_arr(arg)}
      media_set.product(material_set).each do |option_set|
        puts "#{option_set}"
        set << Medium.insert_build(option_set, prepend_set, append_set)
      end
      set
    end
  end

end
