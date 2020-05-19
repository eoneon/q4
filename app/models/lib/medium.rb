class Medium
  include Context
  #Medium::PaintMedia::PaintingOnPaper.builder

  #compound media ##############################################################
  class PaintMedia < Medium
    class Painting < PaintMedia
      def self.builder
        select_field('paint-media', options, search_hsh)
      end

      def self.options
        OptionSet.builder(['painting', 'oil', 'acrylic', 'mixed media'], tags_hsh(0,1))
      end
    end

    class PaintingOnPaper < PaintMedia
      def self.builder
        select_field('paint-media (paper only)', options, search_hsh)
      end

      def self.options
        OptionSet.builder(['watercolor', 'pastel', 'guache', 'sumi ink'], tags_hsh(0,1))
      end
    end

    module OptionSet
      def self.builder(set, tags)
        Option.builder(set.map {|opt_name| Medium.build_name([opt_name, 'painting'])}, tags)
      end
    end

  end

  class DrawingMedia < Medium
    class Drawing < DrawingMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], tags_hsh(0,1))
      end
    end

    class MixedMediaDrawing < DrawingMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['pen and ink drawing', 'pencil drawing'], tags_hsh(0,1))
      end
    end

    class BasicDrawing < DrawingMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['drawing'], search_hsh)
      end
    end
  end

  class EtchingMedia < Medium
    class Etching < EtchingMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], tags_hsh(0,1))
      end
    end

    class BasicEtching < EtchingMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['etching', 'etching (black)', 'etching (sepia)'], tags_hsh(0,1))
      end
    end
  end

  class ReliefMedia < Medium
    class Relief < ReliefMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'], tags_hsh(0,1))
      end
    end

    class BasicRelief < ReliefMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['relief', 'mixed media relief', 'linocut'], tags_hsh(0,1))
      end
    end
  end

  class MixedMedia < Medium
    class BasicMixedMedia < MixedMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['mixed media'], tags_hsh(0,1))
      end
    end

    class AcrylicMixedMedia < MixedMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['mixed media acrylic'], tags_hsh(0,1))
      end
    end

    class Monotype < MixedMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['monotype'], tags_hsh(0,1))
      end
    end
  end

  class SilkscreenMedia < Medium
    class Serigraph < SilkscreenMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['serigraph'], tags_hsh(0,1))
      end
    end

    class Silkscreen < SilkscreenMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['silkscreen'], tags_hsh(0,1))
      end
    end
  end

  class LithographMedia < Medium
    class Lithograph < LithographMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], tags_hsh(0,1))
      end
    end

    class BasicLithograph < LithographMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['lithograph'], tags_hsh(0,1))
      end
    end
  end

  class SericelMedia < Medium
    class Sericel < SericelMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], tags_hsh(0,1))
      end
    end

    class BasicSericel < SericelMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['sericel', 'hand painted sericel'], tags_hsh(0,1))
      end
    end
  end

  class PhotoMedia < Medium
    class StandardPhoto < PhotoMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['photograph', 'photolithograph', 'archival photograph'], tags_hsh(0,1))
      end
    end

    class SingleExposurePhoto < PhotoMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['single exposure photograph'], tags_hsh(0,1))
      end
    end
  end

  #simple media ################################################################

  class Giclee < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['giclee'], search_hsh)
    end
  end

  class PrintMedia < Medium
    class BasicPrint < PrintMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['print', 'fine art print', 'vintage style print'], tags_hsh(0,1))
      end
    end

    class Poster < PrintMedia
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['poster', 'vintage poster', 'concert poster'], tags_hsh(0,1))
      end
    end
  end

  ##############################################################################

  class Embellishment < Medium
    class Embellished < Embellishment
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['hand embellished', 'hand painted', 'artist embellished'], search_hsh)
      end
    end

    class Colored < Embellishment
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted'], search_hsh)
      end
    end
  end

  class Leafing < Medium
    def self.builder
      select_menu(field_class_name, [GoldLeaf.builder, SilverLeaf.builder], search_hsh)
    end

    class GoldLeaf < Leafing
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['goldleaf', 'hand laid goldleaf'], search_hsh)
      end
    end

    class SilverLeaf < Leafing
      def self.builder
        select_field(field_class_name, options, search_hsh)
      end

      def self.options
        Option.builder(['silverleaf', 'hand laid silverleaf'], search_hsh)
      end
    end
  end

  class Remarque < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque'], tags_hsh(0,0))
    end
  end

end
