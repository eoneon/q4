class Medium
  include Context

  def self.builder
    self.subclasses.map {|klass| klass.builder}
  end

  class PaintMedia < Medium
    def self.builder
      options = ['painting', 'oil', 'acrylic', 'mixed media'].map {|opt_name| build_name(['original', opt_name, 'painting'])}
      select_field(field_class_name, Option.builder(options), search_hsh)
    end
  end

  class PaperSpecificPaintMedia < Medium
    def self.builder
      options = ['watercolor', 'pastel', 'guache', 'sumi ink'].map {|opt_name| build_name(['original', opt_name, 'painting'])}
      select_field('paint media (paper only)', Option.builder(options), search_hsh)
    end
  end

  class DrawingMedia < Medium
    def self.builder
      options = ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'].map {|opt_name| build_name(['original', opt_name])}
      select_field(field_class_name, Option.builder(options), search_hsh)
    end
  end

  class MixedMedia < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['mixed media', 'acrylic mixed media', 'monotype']), search_hsh)
    end
  end

  class Serigraph < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['serigraph', 'silkscreen', 'hand pulled serigraph', 'hand pulled silkscreen']), search_hsh)
    end
  end

  class Giclee < Medium
    def self.builder
      radio_button(field_class_name, search_hsh)
      #select_field(field_class_name, Option.builder(['giclee']))
    end
  end

  class Lithograph < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph']), search_hsh)
    end
  end

  class Etching < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']), search_hsh)
    end
  end

  class Relief < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['relief', 'linocut', 'woodblock print', 'block print']), search_hsh)
    end
  end

  class Photography < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['photograph', 'photolithograph', 'archival photograph', 'single exposure photograph']), search_hsh)
    end
  end

  class PrintMedia < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['print', 'fine art print', 'vintage style print']), search_hsh)
    end
  end

  class Poster < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['poster', 'vintage poster']), search_hsh)
    end
  end

  class Sericel < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']), search_hsh)
    end
  end

  class ProductionCel < Medium
    def self.builder
      radio_button('original hand painted production sericel', search_hsh)
      #select_field(field_class_name, Option.builder(['original hand painted production sericel']))
    end
  end

  class Embellishing < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['hand embellished', 'hand painted', 'artist embellished']), search_hsh)
    end
  end

  class Coloring < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']), search_hsh)
    end
  end

  class Leafing < Medium
    def self.builder
      select_menu(field_class_name, [GoldLeaf.builder, SilverLeaf.builder], search_hsh)
    end

    class GoldLeaf < Leafing
      def self.builder
        select_field(field_class_name, Option.builder(['goldleaf', 'hand laid goldleaf']), search_hsh)
      end
    end

    class SilverLeaf < Leafing
      def self.builder
        select_field(field_class_name, Option.builder(['silverleaf', 'hand laid silverleaf']), search_hsh)
      end
    end
  end

  class Remarque < Medium
    def self.builder
      select_field(field_class_name, Option.builder(['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque']), search_hsh)
    end
  end

end
