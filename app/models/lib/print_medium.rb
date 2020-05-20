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
    def self.option_set(*idx_set)
      if idx_set.empty?
        set.map{|a| a[1..-1]}.flatten
      elsif idx_set.count == 1
        set.assoc(idx_set[0])[1..-1]
      elsif idx_set.count > 1
        idx_set.map{|i| set.assoc(i)[1..-1]}.flatten
      end
    end

    class MixedPrintOnPaperOnly < FSO
      def self.field_name(field_class_name)
        "#{field_class_name} on paper"
      end

      def self.builder
        option_set.map{|klass| field_set(field_name(klass.field_class_name), [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
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
      def self.field_name(field_class_name)
        "#{field_class_name} on paper"
      end

      def self.builder
        option_set.map{|klass| field_set(field_name(klass.field_class_name), [Medium::Embellishment::Colored.builder, klass.builder, Material::Paper.builder], h={kind: 'medium', sub_kind: klass.klass_name.underscore})}
      end

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
    end #end of PrintOnPaper

  end


end
