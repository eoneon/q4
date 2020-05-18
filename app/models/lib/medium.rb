class Medium
  include Context

  class Paint < Medium
    def self.builder
      select_field('paint-media', options, search_hsh)
    end

    def self.options
      Option.builder(['painting', 'oil', 'acrylic', 'mixed media'].map {|opt_name| build_name([opt_name, 'painting'])}, search_hsh)
    end
  end

  class PaperSpecificPaint < Medium
    def self.builder
      select_field('paint-media (paper only)', options, search_hsh)
    end

    def self.options
      Option.builder(['watercolor', 'pastel', 'guache', 'sumi ink'].map {|opt_name| build_name([opt_name, 'painting'])}, search_hsh)
    end
  end

  class DrawingMedia < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'], search_hsh)
    end
  end

  class MixedMedia < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['mixed media', 'acrylic mixed media', 'monotype'], search_hsh)
    end
  end

  class Serigraph < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['serigraph', 'silkscreen', 'hand pulled serigraph', 'hand pulled silkscreen'], search_hsh)
    end
  end

  class Giclee < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['giclee'], search_hsh)
    end
  end

  class Lithograph < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph'], search_hsh)
    end
  end

  class Etching < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'], search_hsh)
    end
  end

  class Relief < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['relief', 'linocut', 'woodblock print', 'block print'], search_hsh)
    end
  end

  class Photography < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['photograph', 'photolithograph', 'archival photograph', 'single exposure photograph'], search_hsh)
    end
  end

  class PrintMedia < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['print', 'fine art print', 'vintage style print'], search_hsh)
    end
  end

  class Poster < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['poster', 'vintage poster'], search_hsh)
    end
  end

  class Sericel < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'], search_hsh)
    end
  end

  class ProductionCel < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['sericel', 'hand painted sericel'], search_hsh)
    end
  end

  class ProductionDrawing < Medium
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['drawing'], search_hsh)
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

    class Coloring < Embellishment
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
      Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque'], search_hsh)
    end
  end

end
