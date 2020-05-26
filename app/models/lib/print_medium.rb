class PrintMedium
  include Context
  #PrintMedium::SFO::LithographMedia::Lithograph.tags
  class SFO < PrintMedium
    def self.tags
      tags_hsh(0,-2)
    end

    def self.builder
      select_field(field_class_name, options, tags_hsh(0,-2))
    end

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

    class SericelMedia < PrintMedia
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
  #set = PrintMedium::FSO.builder
  class FSO < PrintMedium
    ############################################################################
    #add photo and sericel
    def self.builder
      [StandardPrint, NumberedPrint::LimitedEdition, NumberedPrint::UniqueVariation, OneOfAKindPrint].each do |option_group|
        option_group.options.each do |opt_hsh|
          field_set(build_name(opt_hsh), build_options(opt_hsh), opt_hsh[:tags])
        end
      end
    end

    ############################################################################

    def self.build_name(opt_hsh)
      options, opt_names = opt_hsh[:options], option_names(opt_hsh)
      name_set=[]
      options.each do |opt_class|
        kind, name = opt_class.tags[:kind], decamelize(opt_class.klass_name)
        name_set << build_name_set(opt_names, kind, name)
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

    def self.build_options(opt_hsh)
      opt_hsh[:options].map{|opt| opt.builder}.flatten
    end

    ############################################################################

    def self.update_opt_hsh(opt_hsh, idx, category, append_value=nil)
      opt_hsh[:options] = opt_hsh[:options].insert(idx, category)
      opt_hsh[:options].append(append_value) if append_value.present?
      opt_hsh
    end

    def self.insert_idx(opt_hsh)
      option_names(opt_hsh).include?('embellishment') ? 1 : 0
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

    def self.option_names(opt_hsh)
      opt_hsh[:options].map{|klass| klass.tags[:kind]}
    end

    ############################################################################

    class StandardPrint < FSO
      def self.options
        [MixedPrintOnPaperOnly, MixedPrintOnPaper, MixedPrintOnCanvas, MixedPrintOnStandardMaterial, HandPulledPrintOnPaper, HandPulledPrintOnCanvas, PrintOnPhotoPaper, PrintOnSericel].map{|option_group| option_group.options.map{|opt_hsh| opt_hsh}}.flatten
      end
    end

    class NumberedPrint < FSO
      class LimitedEdition < NumberedPrint
        def self.options
          StandardPrint.options.map{|opt_hsh| update_opt_hsh(opt_hsh, insert_idx(opt_hsh), Category::LimitedEdition, Numbering)}
        end
      end

      class UniqueVariation < NumberedPrint
        def self.options
          [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly].map{|option_group| option_group.options.flatten.map{|opt_hsh| update_opt_hsh(opt_hsh, insert_idx(opt_hsh), Category::UniqueVariation, Numbering)}}.flatten
        end
      end
    end

    class OneOfAKindPrint < FSO
      def self.options
        [HandPulledPrintOnCanvas, HandPulledPrintOnPaper, MixedPrintOnPaperOnly, PrintOnPaper].map{|option_group| option_group.options.map{|opt_hsh| update_opt_hsh(opt_hsh, 0, Category::OriginalMedia::OneOfAKind)}}.flatten
      end
    end

    ############################################################################

    class PrintOnSericel < FSO
      def self.options
        OnMaterial.option_set(media_set, Material::Sericel)
      end

      def self.set
        [
          [0,
            SFO::SericelMedia::BasicSericel
          ]
        ]
      end
    end

    class PrintOnPhotoPaper < FSO
      def self.options
        OnMaterial.option_set(media_set, Material::PhotographyPaper)
      end

      def self.set
        [
          [0,
            SFO::PhotoMedia::Photograph,
            SFO::PhotoMedia::SingleExposurePhoto
          ]
        ]
      end
    end

    class PrintOnPaper < FSO
      def self.options
        #OnPaper.option_set(media_set)
        OnMaterial.option_set(media_set, Material::Paper)
      end

      def self.set
        [
          [0,
            SFO::MixedMedia::Monotype,
            SFO::MixedMedia::AcrylicMixedMedia
          ]
        ]
      end
    end

    class PrintOnPaperWithRemarque < FSO
      def self.options
        OnPaperWithRemarque.option_set(media_set)
      end

      def self.set
        [
          [0,
            SFO::PrintMedia::Poster
          ]
        ]
      end
    end

    class PrintOnCanvas < FSO
      def self.options
        OnCanvas.option_set(media_set)
      end

      def self.set
        [
          [0,
            SFO::MixedMedia::AcrylicMixedMedia
          ]
        ]
      end
    end

    class MixedPrintOnPaperOnly < FSO
      def self.options
        MixedOnPaper.option_set(media_set)
      end

      def self.set
        [
          [0,
            SFO::LithographMedia::Lithograph,
            SFO::EtchingMedia::Etching,
            SFO::ReliefMedia::Relief
          ]
        ]
      end
    end

    class MixedPrintOnPaper < FSO
      def self.options
        MixedOnPaper.option_set(media_set)
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

    class BasicMixedPrintOnPaper < FSO
      def self.options
        MixedOnPaper.option_set(media_set)
      end

      def self.set
        [
          [0,
            SFO::EtchingMedia::BasicEtching,
            SFO::ReliefMedia::BasicRelief
          ]
        ]
      end
    end #end of BasicMixedPrintOnPaper

    class MixedPrintOnCanvas < FSO
      def self.options
        MixedOnStandardMaterial.option_set(MixedPrintOnPaper.media_set, [Material::Canvas, Material::WrappedCanvas])
      end
    end #end of MixedPrintOnCanvas

    class MixedPrintOnStandardMaterial < FSO
      def self.options
        MixedOnStandardMaterial.option_set(MixedPrintOnPaper.media_set, [Material::Wood, Material::WoodBox, Material::Metal, Material::MetalBox, Material::Acrylic])
      end
    end #end of MixedPrintOnCanvas

    ############################################################################

    class HandPulledPrintOnPaper < FSO
      def self.options
        HandPulledOnPaper.option_set(MixedPrintOnPaper.media_set(0))
      end
    end #end of HandPulledPrintOnPaper

    class HandPulledPrintOnCanvas < FSO
      def self.options
        HandPulledOnCanvas.option_set(MixedPrintOnPaper.media_set(0))
      end
    end #end of HandPulledPrintOnPaper
  end

  ############################################################################

  module OnMaterial
    def self.option_set(media_set, material_klass)
      media_set.map{|medium_klass| h={options: [medium_klass, material_klass], tags: medium_klass.tags}}.flatten
    end
  end

  module OnPaper
    def self.option_set(media_set)
      media_set.map{|medium_klass| h={options: [medium_klass, Material::Paper], tags: medium_klass.tags}}.flatten
    end
  end

  module OnPaperWithRemarque
    def self.option_set(media_set)
      media_set.map{|medium_klass| f={options: [medium_klass, Material::Paper, Medium::Remarque], tags: medium_klass.tags}}.flatten
    end
  end

  module OnCanvas
    def self.option_set(media_set)
      #media_set.map{|medium_klass| f={options: [medium_klass, Material::Canvas], tags: medium_klass.tags}}.flatten
      [Material::Canvas, Material::WrappedCanvas].map{|material_class| media_set.map{|medium_klass| f={options: [medium_klass, material_class], tags: medium_klass.tags}}}.flatten
    end
  end

  module MixedOnPaper
    def self.option_set(media_set)
      media_set.map{|medium_klass| f={options: [Medium::Embellishment::Colored, medium_klass, Material::Paper, Medium::Leafing, Medium::Remarque], tags: medium_klass.tags}}.flatten
    end
  end

  module HandPulledOnPaper
    def self.option_set(media_set)
      media_set.map{|medium_klass| f={options: [Medium::Embellishment::Colored, Medium::HandPulled, medium_klass, Material::Paper], tags: medium_klass.tags}}.flatten
    end
  end

  module HandPulledOnCanvas
    def self.option_set(media_set)
      #media_set.map{|medium_klass| f={field_name: FSO.field_name(medium_klass, Material::Paper), options: [Medium::Embellishment::Colored, Medium::HandPulled, medium_klass, Material::Paper], tags:  h={kind: 'medium', sub_kind: medium_klass.klass_name.underscore}}}.flatten
      [Material::Canvas, Material::WrappedCanvas].map{|material_class| media_set.map{|medium_klass| f={options: [Medium::Embellishment::Embellished, Medium::HandPulled, medium_klass, material_class], tags: medium_klass.tags}}}.flatten
    end
  end

  module MixedOnStandardMaterial
    def self.option_set(media_set, material_set)
      material_set.map{|material_class| media_set.map{|medium_klass| f={options: [Medium::Embellishment::Embellished, medium_klass, material_class], tags: medium_klass.tags}}}.flatten
    end
  end

end

# module HandPulled
#   def self.option_set(media_set, material_klass)
#     embellishing_field = material.klass_name == 'Paper' ? Medium::Embellishment::Colored : Medium::Embellishment::Embellished
#     media_set.map{|medium_klass| f={field_name: FSO.field_name(medium_klass, material_klass), options: [embellishing_field, Medium::HandPulled, medium_klass, material_klass], tags:  h={kind: 'medium', sub_kind: medium_klass.klass_name.underscore}}}.flatten
#   end
# end
