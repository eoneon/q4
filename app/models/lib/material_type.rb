class MaterialType
  class FlatMaterial < MaterialType
    def self.set
      [Canvas,WrappedCanvas,Paper,Wood,Acrylic,Metal,MetalBox,WoodBox]
    end
  end

  class PhotographyPaper < MaterialType
    def self.set
      PhotographyPaper
    end
  end

  class AnimationPaper < MaterialType
    def self.set
      AnimationPaper
    end
  end Sericel

  class Sericel < MaterialType
    def self.set
      Sericel
    end
  end

  module Canvas
    def self.set
      ['canvas', 'canvas board', 'textured canvas']
    end
  end

  module WrappedCanvas
    def self.set
      ['gallery wrapped canvas', 'stretched canvas']
    end
  end

  module Paper
    def self.set
      ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'sommerset paper', 'mother of pearl paper']
    end
  end

  module Wood
    def self.set
      ['wood', 'wood panel', 'board']
    end
  end

  module Acrylic
    def self.set
      ['acrylic', 'acrylic panel', 'resin']
    end
  end

  module Metal
    def self.set
      ['metal', 'metal panel', 'aluminum', 'aluminum panel']
    end
  end

  module MetalBox
    def self.set
      ['metal box']
    end
  end

  module WoodBox
    def self.set
      ['wood box']
    end
  end

  module PhotographyPaper
    def self.set
      ['paper', 'photography paper', 'archival grade paper']
    end
  end

  module AnimationPaper
    def self.set
      ['paper', 'animation paper']
    end
  end

  module Sericel
    def self.set
      ['sericel', 'sericel with background', 'sericel with lithographic background']
    end
  end
end
