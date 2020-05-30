class Medium
  include Context

  def self.tags
    if split_class.include?('SFO')
      tags_hsh(2,-1)
    elsif split_class.include?('FSO')
      tags_hsh(0,2)
    end
  end
  # Medium::SFO.sub_media
  class SFO < Medium
    def self.sub_media
      flat_class_set(self)
    end

    def self.field_name
      class_set = split_class[split_class.index('SFO')+1..-1] #.map{|name| decamelize(name)}.flatten.uniq
      if class_set.count == 1
        decamelize(class_set[0], '-')
      elsif class_set.count == 2
        format_select_field_name(class_set.map{|klass| decamelize(klass)}.join(" ").split(" ").uniq.join(" "))
      end
    end

    def self.format_select_field_name(words)
      if word = ['paper only', 'basic', 'standard', 'serigraph', 'acrylic', 'monotype', 'single exposure', 'poster'].detect{|word| words.index(word)}
        [words[0..words.index(word)-1].strip.split(" ").join("-"), "(#{word})"].join(" ")
      elsif word = ['production media'].detect{|word| words.index(word)}
        [word.split(" ").join("-"), "(#{words[word.length..-1].strip})"].join(" ")
      else
        words.split(" ").join("-")
      end
    end

    def self.builder
      select_field(field_name, options, tags)
    end

    ############################################################################
    class PaintingMedia < SFO
      class StandardPainting < PaintingMedia
        def self.options
          OptionSet.builder(['painting', 'oil', 'acrylic', 'mixed media'], tags)
        end
      end

      class PaintingPaperOnly < PaintingMedia
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
      class StandardDrawing < DrawingMedia
        def self.options
          Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], tags)
        end
      end

      class MixedMediaDrawing < DrawingMedia
        def self.options
          Option.builder(['pen and ink drawing', 'pencil drawing'], tags)
        end
      end
    end

    class ProductionMedia < SFO
      class ProductionDrawing < ProductionMedia
        def self.options
          Option.builder(['drawing'], tags)
        end
      end

      class ProductionSericel < ProductionMedia
        def self.options
          Option.builder(['hand painted production cel'], tags)
        end
      end
    end

    ############################################################################

    class LithographMedia < SFO
      class Lithograph < LithographMedia
        def self.options
          Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], tags)
        end
      end

      class BasicLithograph < LithographMedia
        def self.options
          Option.builder(['lithograph'], tags)
        end
      end
    end

    class EtchingMedia < SFO
      class Etching < EtchingMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], tags)
        end
      end

      class MixedMediaEtching < EtchingMedia
        def self.options
          Option.builder(['etching', 'etching (black)', 'etching (sepia)'], tags)
        end
      end
    end

    class ReliefMedia < SFO
      class Relief < ReliefMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'], tags)
        end
      end

      class MixedMediaRelief < ReliefMedia
        def self.options
          Option.builder(['relief', 'mixed media relief', 'linocut'], tags)
        end
      end
    end

    class SilkscreenMedia < SFO
      class Serigraph < SilkscreenMedia
        def self.options
          Option.builder(['serigraph'], tags)
        end
      end

      class Silkscreen < SilkscreenMedia
        def self.options
          Option.builder(['silkscreen'], tags)
        end
      end
    end

    class Giclee < SFO
      def self.options
        Option.builder(['giclee'], tags)
      end
    end

    class MixedMedia < SFO
      class StandardMixedMedia < MixedMedia
        def self.options
          Option.builder(['mixed media'], tags)
        end
      end

      class AcrylicMixedMedia < MixedMedia
        def self.options
          Option.builder(['mixed media acrylic'], tags)
        end
      end

      class Monotype < MixedMedia
        def self.options
          Option.builder(['monotype'], tags)
        end
      end
    end

    class PhotographMedia < SFO
      class Photograph < PhotographMedia
        def self.options
          Option.builder(['photograph', 'photolithograph', 'archival photograph'], tags)
        end
      end

      class SingleExposurePhotograph < PhotographMedia
        def self.options
          Option.builder(['single exposure photograph'], tags)
        end
      end
    end

    class PrintMedia < SFO
      class BasicPrint < PrintMedia
        def self.options
          Option.builder(['print', 'fine art print', 'vintage style print'], tags)
        end
      end

      class Poster < PrintMedia
        def self.options
          Option.builder(['poster', 'vintage poster', 'concert poster'], tags)
        end
      end
    end

    class SericelMedia < SFO
      def self.options
        Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], tags)
      end
    end

  end

  ##############################################################################
  #set = Medium::FSO.builder
  class FSO < Medium
    def self.builder
      set=[]
      @sub_media = Medium::SFO.sub_media.map{|i| i.tags[:sub_kind]}
      [OriginalPainting, OriginalPaintingPaperOnly, OriginalDrawing, OriginalMixedMediaDrawing, OriginalProductionDrawing, OriginalProductionSericel, OneOfAKindPrint, NumberedPrint::LimitedEdition, NumberedPrint::UniqueVariation, StandardPrint].each do |option_group|
        option_group.options.each do |opt_hsh|
          field_set(opt_hsh[:field_name], opt_hsh[:options], build_tags(opt_hsh))
        end
      end
      set
    end

    def self.sub_media
      flat_class_set(self) - StandardPrint.class_set
    end

    ############################################################################

    def self.build_name(options, name_set=[])
      options.each do |klass|
        kind, name = klass.tags[:kind], decamelize(klass.klass_name)
        name_set << build_name_set(option_names(options), kind, name)
      end
      format_field_set_name(name_set.join(" "))
    end

    def self.format_field_set_name(words)
      if word = ['paper only', 'basic', 'standard'].detect{|word| words.index(word)}
        new_word = word == 'standard' ? "" : "(#{word})"
        words.sub(word, new_word)
      else
        words
      end
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

    def self.ltd_idx(option_set)
      option_names(option_set).include?('embellishment') ? 1 : 0
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

    # def self.build_tags(opt_hsh)
    #   opt_hsh[:options].map{|klass| opt_hsh[:tags][klass.tags["kind"].to_sym] = klass.tags["sub_kind"]}
    #   opt_hsh[:tags].compact
    # end

    def self.build_tags(opt_hsh)
      opt_hsh[:options].each do |klass|
        if @sub_media.include?(klass.tags["sub_kind"])
          opt_hsh[:tags][:sub_medium] = klass.tags["sub_kind"]
        else
          opt_hsh[:tags][klass.tags["kind"].to_sym] = klass.tags["sub_kind"]
        end
      end
      opt_hsh[:tags].compact
    end

    ############################################################################
    def self.options
      option_sets.map{|option_set| h={field_name: build_name(option_set), options: build_options(option_set), tags: tags}}
    end

    class StandardPrint < FSO
      def self.option_sets
        set=[]
        #[MixedPrintOnPaperOnly, MixedPrintOnPaper, MixedPrintOnCanvas, MixedPrintOnStandardMaterial, HandPulledPrintOnPaper, HandPulledPrintOnCanvas, PhotoPrint, SericelPrint].each do |option_group|
        class_set.each do |option_group|
          option_group.option_sets.each do |option_set|
            set << option_set
          end
        end
        set
      end
    end

    def self.class_set
      [MixedPrintOnPaperOnly, MixedPrintOnPaper, MixedPrintOnCanvas, MixedPrintOnStandardMaterial, HandPulledPrintOnPaper, HandPulledPrintOnCanvas, PhotoPrint, SericelPrint]
    end
    #Medium::FSO::NumberedPrint::LimitedEdition.options
    class NumberedPrint < FSO
      class LimitedEdition < NumberedPrint
        def self.option_sets
          #StandardPrint.option_sets.map {|option_set| option_set_build(option_set, Category::LimitedEdition, Numbering)}
          StandardPrint.option_sets.map {|option_set| option_set_build(options: option_set, append_set: Numbering, insert_set: [[ltd_idx(option_set), Category::LimitedEdition]])}
        end
      end
      #Medium::FSO::NumberedPrint::UniqueVariation.options
      class UniqueVariation < NumberedPrint
        def self.option_sets
          set=[]
          [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly].each do |option_group|
            option_group.option_sets.each do |option_set|
              set << option_set_build(options: option_set, append_set: Numbering, insert_set: [[ltd_idx(option_set), Category::UniqueVariation]])
            end
          end
          set
        end
      end
    end
    #Medium::FSO::OneOfAKindPrint.options
    class OneOfAKindPrint < FSO
      def self.option_sets
        set=[]
        [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly, MixedMediaOnPaper].each do |option_group|
          option_group.option_sets.each do |option_set|
            set << prepend_build(option_set, Category::OriginalMedia::OneOfAKind)
          end
        end
        set
      end
    end
    #Medium::FSO::OriginalPainting.options
    class OriginalPainting < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::PaintingMedia::StandardPainting], material_set: Material::StandardMaterial.options, prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalPaintingPaperOnly < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::PaintingMedia::PaintingPaperOnly], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalDrawing < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::DrawingMedia::StandardDrawing], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original])
      end
    end

    class OriginalMixedMediaDrawing < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::DrawingMedia::MixedMediaDrawing], material_set: [Material::Paper], prepend_set: [Category::OriginalMedia::Original], append_set: [SubMedium::SMO::Leafing])
      end
    end

    class OriginalProductionDrawing < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::ProductionMedia::ProductionDrawing], material_set: [Material::AnimationPaper], prepend_set: [Category::OriginalMedia::OriginalProduction])
      end
    end

    class OriginalProductionSericel < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::ProductionMedia::ProductionSericel], material_set: [Material::Sericel], prepend_set: [Category::OriginalMedia::OriginalProduction])
      end
    end

    class SericelPrint < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::SericelMedia], material_set: [Material::Sericel])
      end
    end

    class PhotoPrint < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::PhotographMedia::Photograph, SFO::PhotographMedia::SingleExposurePhotograph], material_set: [Material::PhotographyPaper])
      end
    end

    class MixedMediaOnPaper < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::MixedMedia::Monotype, SFO::MixedMedia::AcrylicMixedMedia], material_set: [Material::Paper])
      end
    end

    class PrintOnPaperWithRemarque < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::PrintMedia::Poster], material_set: [Material::Paper], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class PrintOnCanvas < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::MixedMedia::AcrylicMixedMedia], material_set: [Material::Canvas, Material::WrappedCanvas])
      end
    end

    class MixedPrintOnPaperOnly < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::LithographMedia::Lithograph, SFO::EtchingMedia::Etching, SFO::ReliefMedia::Relief], material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class BasicMixedPrintOnPaper < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: [SFO::EtchingMedia::MixedMediaEtching, SFO::ReliefMedia::MixedMediaRelief], material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored], append_set: [SubMedium::SFO::Remarque])
      end
    end

    ############################################################################
    # Medium::FSO::MixedPrintOnPaper.media_set
    # Medium::FSO::MixedPrintOnPaper.options
    class MixedPrintOnPaper < FSO
      def self.option_sets
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
            SFO::MixedMedia::StandardMixedMedia,
            SFO::PrintMedia::BasicPrint
          ]
        ]
      end
    end #end of MixedPrintOnPaper

    ############################################################################
    # Medium::FSO::MixedPrintOnPaper.media_set
    # Medium::FSO::MixedPrintOnPaper.options
    class MixedPrintOnCanvas < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set, material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Colored])
      end
    end

    class MixedPrintOnStandardMaterial < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set, material_set: [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic], prepend_set: [SubMedium::SFO::Embellishment::Embellished], append_set: [SubMedium::SFO::Remarque])
      end
    end #end of MixedPrintOnCanvas

    class HandPulledPrintOnPaper < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set(0), material_set: [Material::Paper], prepend_set: [SubMedium::SFO::Embellishment::Colored, SubMedium::RBF::HandPulled], append_set: [SubMedium::SFO::Remarque])
      end
    end

    class HandPulledPrintOnCanvas < FSO
      def self.option_sets
        FieldSetOption.builder(media_set: MixedPrintOnPaper.media_set(0), material_set: [Material::Canvas, Material::WrappedCanvas], prepend_set: [SubMedium::SFO::Embellishment::Embellished, SubMedium::RBF::HandPulled])
      end
    end
  end

  module FieldSetOption
    def self.builder(media_set:, material_set:, prepend_set: [], append_set: [], set: [])
      media_set, material_set, prepend_set, append_set = [media_set, material_set, prepend_set, append_set].map{|arg| Medium.arg_as_arr(arg)}
      media_set.product(material_set).each do |option_set|
        set << Medium.option_set_build(options: option_set, prepend_set: prepend_set, append_set: append_set)
      end
      set
    end
  end

end
