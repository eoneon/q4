class MediumType
  class LimitedEditionPrint
  end

  class UniqueVariationPrint
  end

  class StandardPrint
  end

  class Painting
  end

  class PaintingOnPaper
  end

  class Drawing
  end

  class MixedMediaDrawing
  end

  module Sericel
    def self.set
      ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
    end
  end

  module BasicPrint
    def self.set
      ['print', 'fine art print', 'vintage style print']
    end
  end

  module HandEmbellished
    def self.set
      ['hand embellished', 'hand painted', 'artist embellished']
    end
  end

  module HandColored
    def self.set
      ['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
    end
  end

  module GoldLeaf
    def self.set
      ['goldleaf', 'hand laid goldleaf']
    end
  end

  module SilverLeaf
    def self.set
      ['silverleaf', 'hand laid silverleaf']
    end
  end

  module HandPulled
    def self.set
      ['hand pulled']
    end
  end
end
  ##################
  # module Painting
  #   module Painting
  #   end
  #
  #   module PaintingOnPaper
  #   end
  # end

  # module Drawing
  #   module Drawing
  #   end
  #
  #   module MixedMediaDrawing
  #   end
  # end
  #
  # module Production
  #   module ProductionDrawing
  #   end
  #
  #   module ProductionSericel
  #   end
  #
  #   module ProductionSet
  #   end
  # end

  ##################

  # module Print
  #   module Serigraph
  #   end
  #
  #   module Giclee
  #   end
  #
  #   module MixedMedia
  #   end
  #
  #   module HandPulled
  #   end
  #
  #   module OnPaper
  #     module Lithograph
  #     end
  #
  #     module Etching
  #     end
  #
  #     module Relief
  #     end
  #
  #     module Poster
  #     end
  #   end
  #
  #   module Photograph
  #   end
  #
  #   module Sericel
  #   end
  #
  #   module BasicPrint
  #   end
  #
  # end
