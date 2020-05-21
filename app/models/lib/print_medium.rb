class PrintMedium
  include Context

  class SFO < PrintMedium
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
  end

  ##############################################################################
  #PrintMedium::FSO::MixedPrintOnPaper.builder
  class FSO < PrintMedium
    def self.field_name(klass, material_class)
      [klass.field_class_name, 'on', material_class.field_class_name].join(" ")
    end

    def self.media_set(*idx_set)
      if idx_set.empty?
        set.map{|a| a[1..-1]}.flatten
      elsif idx_set.count == 1
        set.assoc(idx_set[0])[1..-1]
      elsif idx_set.count > 1
        idx_set.map{|i| set.assoc(i)[1..-1]}.flatten
      end
    end

    class MixedPrintOnPaperOnly < FSO
      def self.options
        MixedOnPaper.option_set(media_set)
        #media_set.map{|klass| f={field_name: field_name(klass, Material::Paper), options: [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end

      # def self.builder
      #   media_set.map{|klass| field_set(field_name(klass, Material::Paper), [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
      # end

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
        #media_set.map{|klass| f={field_name: field_name(klass, Material::Paper), options: [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end

      # def self.builder
      #   media_set.map{|klass| field_set(field_name(klass, Material::Paper), [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
      # end

      def self.set
        [
          [0,
            SFO::SilkscreenMedia::Serigraph,
            SFO::SilkscreenMedia::Silkscreen,
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
        #media_set.map{|klass| f={field_name: field_name(klass, Material::Paper), options: [Medium::Embellishment::Colored.builder, klass.builder, Material::Canvas.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end
      # def self.builder
      #   media_set.map{|klass| field_set(field_name(klass, Material::Paper), [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
      # end

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
        #MixedPrintOnPaper.media_set.map{|klass| f={field_name: field_name(klass, Material::Canvas), options: [Medium::Embellishment::Embellished.builder, klass.builder, Material::Canvas.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end
      # def self.builder
      #   MixedPrintOnPaper.media_set.map{|klass| field_set(field_name(klass, Material::Canvas), [Medium::Embellishment::Embellished.builder, klass.builder, Material::Canvas.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
      # end
    end #end of MixedPrintOnCanvas

    class HandPulledPrintOnPaper < FSO
      #MixedPrintOnPaper
      def self.options
        MixedOnPaper.option_set(MixedPrintOnPaper.media_set(0))
        #MixedPrintOnPaper.media_set.map{|klass| f={field_name: field_name(klass, Material::Canvas), options: [Medium::Embellishment::Embellished.builder, klass.builder, Material::Canvas.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end

    end #end of HandPulledPrintOnPaper

    class HandPulledPrintOnCanvas < FSO
      #MixedPrintOnPaper
      def self.options
        MixedOnStandardMaterial.option_set(MixedPrintOnPaper.media_set(0), [Material::Canvas, Material::WrappedCanvas])
        #MixedPrintOnPaper.media_set.map{|klass| f={field_name: field_name(klass, Material::Canvas), options: [Medium::Embellishment::Embellished.builder, klass.builder, Material::Canvas.builder], tags:  h={kind: 'medium', sub_kind: klass.klass_name.underscore}}
      end

    end #end of HandPulledPrintOnPaper

  end

  module MixedOnPaper
    def self.option_set(media_set)
      media_set.map{|medium_klass| f={field_name: field_name(medium_klass, Material::Paper), options: [Medium::Embellishment::Colored, medium_klass, Material::Paper, Medium::Leafing, Medium::Remarque], tags:  h={kind: 'medium', sub_kind: medium_klass.klass_name.underscore}}.flatten
    end
  end

  module MixedOnStandardMaterial
    def self.option_set(media_set, material_set)
      material_set.map{|material_class| media_set.map{|medium_klass| f={field_name: field_name(medium_klass, material_class), options: [Medium::Embellishment::Embellished, medium_klass, material_class], tags:  h={kind: 'medium', sub_kind: medium_klass.klass_name.underscore}}}}.flatten
    end
  end

  module CategoryAndNumbering
    def self.option_set(medium_option_set, category=nil)
      #
    end
  end

end
