class Medium
  include Context

  class PaintMedia < Medium
    def self.builder
      #klass_name = decamelize(self.slice_class(-1))
      #options = ['painting', 'oil', 'acrylic', 'mixed media'].map {|opt_name| ['original', opt_name, 'painting'].uniq.join(" ")}
      options = ['painting', 'oil', 'acrylic', 'mixed media'].map {|opt_name| build_name(['original', opt_name, 'painting'])}
      #Select.field(item_name, Option.builder(options))
      select_field_group(field_class_name, Option.builder(options))
    end
  end

  class PaintOnPaperMedia < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      options = ['watercolor', 'pastel', 'guache', 'sumi ink'].map {|opt_name| ['original', opt_name, 'painting'].uniq.join(" ")}
      Select.field(klass_name, Option.builder(options))
    end
  end

  class DrawingMedia < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      options = ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch',  'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'].map {|opt_name| ['original', opt_name].join(" ")}
      Select.field(klass_name, Option.builder(options))
    end
  end

  class MixedMedia < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['mixed media', 'acrylic mixed media', 'monotype']))
    end
  end

  class Serigraph < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['serigraph', 'silkscreen', 'hand pulled serigraph', 'hand pulled silkscreen']))
    end
  end

  class Giclee < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['giclee']))
    end
  end

  class Lithograph < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph']))
    end
  end

  class Etching < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']))
    end
  end

  class Relief < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['relief', 'linocut', 'woodblock print', 'block print']))
    end
  end

  class Photograph < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['photograph', 'photolithograph', 'archival photograph', 'single exposure photograph']))
    end
  end

  class PrintMedia < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['print', 'fine art print', 'vintage style print']))
    end
  end

  class Poster < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['poster', 'vintage poster']))
    end
  end

  class Sericel < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']))
    end
  end

  class ProductionCel < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['original hand painted production sericel']))
    end
  end

  class Embellished < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['hand embellished', 'hand painted', 'artist embellished']))
    end
  end

  class HandColored < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']))
    end
  end

  class GoldLeaf < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['goldleaf', 'hand laid goldleaf']))
    end
  end

  class SilverLeaf < Medium
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      Select.field(klass_name, Option.builder(['silverleaf', 'hand laid silverleaf']))
    end
  end


end
