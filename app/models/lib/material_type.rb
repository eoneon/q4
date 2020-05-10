class MaterialType
  class FlatMaterial < MaterialType
    def self.set
      [Canvas,WrappedCanvas,Paper,Wood,Acrylic,Metal,MetalBox,WoodBox]
    end
  end

  class Canvas < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['canvas', 'canvas board', 'textured canvas']
      end
    end
  end

  class WrappedCanvas < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['gallery wrapped canvas', 'stretched canvas']
      end
    end
  end

  class Paper < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']
      end
    end
  end

  class Wood < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['wood', 'wood panel', 'board']
      end
    end
  end

  class Acrylic < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['acrylic', 'acrylic panel', 'resin']
      end
    end
  end

  class Metal < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['metal', 'metal panel', 'aluminum', 'aluminum panel']
      end
    end
  end

  class MetalBox < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['metal box']
      end
    end
  end

  class WoodBox < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['wood box']
      end
    end
  end

  class PhotographyPaper < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['paper', 'photography paper', 'archival grade paper']
      end
    end
  end

  class AnimationPaper < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['paper', 'animation paper']
      end
    end
  end

  class Sericel < MaterialType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['sericel', 'sericel with background', 'sericel with lithographic background']
      end
    end
  end
end
