class FlatMediumType
  include Context
  
  class Painting < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['painting', 'oil', 'acrylic', 'mixed media']
      end
    end
  end

  class PaintingOnPaper < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['watercolor', 'pastel', 'guache', 'sumi ink']
      end
    end
  end

  class Drawing < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch',  'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
      end
    end
  end

  class MixedMediaDrawing < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['drawing', 'pen and ink drawing', 'pencil drawing']
      end
    end
  end

  class MixedMedia < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['mixed media', 'acrylic mixed media', 'monotype']
      end
    end
  end

  class Serigraph < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['serigraph', 'silkscreen', 'hand pulled serigraph', 'hand pulled silkscreen']
      end
    end
  end

  class Giclee < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['giclee']
      end
    end
  end

  class Lithograph < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['lithograph', 'offset lithograph', 'original lithograph', 'hand pulled lithograph']
      end
    end
  end

  class Etching < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
      end
    end
  end

  class Relief < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['relief', 'linocut', 'woodblock print', 'block print']
      end
    end
  end

  class Poster < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['poster', 'vintage poster']
      end
    end
  end

  class Photograph < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['photograph', 'photolithograph', 'archival photograph', 'single exposure photograph']
      end
    end
  end

  class Sericel < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
      end
    end
  end

  class ProductionCel < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['hand painted production sericel']
      end
    end
  end

  class BasicPrint < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['print', 'fine art print', 'vintage style print']
      end
    end
  end

  class Poster < FlatMediumType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['poster', 'vintage poster']
      end
    end
  end
end
  # module LimitedEdition
  #   def self.set
  #     ['limited edition', 'sold out limited edition']
  #   end
  # end
  #
  # module UniqueVariation
  #   def self.set
  #     ['unique variation']
  #   end
  # end
  #
  # module Painting
  #   def self.set
  #     ['painting', 'oil', 'acrylic', 'mixed media']
  #   end
  # end

  # module PaintingOnPaper
  #   def self.set
  #     ['watercolor', 'pastel', 'guache', 'sumi ink']
  #   end
  # end

  # module Drawing
  #   def self.set
  #     ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch',  'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing']
  #   end
  # end

  # module MixedMedia
  #   def self.set
  #     ['acrylic mixed media', 'monotype']
  #   end
  # end

  # module Serigraph
  #   def self.set
  #     ['serigraph', 'silkscreen']
  #   end
  # end

  # module Giclee
  #   def self.set
  #     ['giclee']
  #   end
  # end

  # module MixedMediaPrint
  #   def self.set
  #     ['mixed media']
  #   end
  # end

  # module Lithograph
  #   def self.set
  #     ['lithograph', 'offset lithograph', 'original lithograph']
  #   end
  # end

  # module Etching
  #   def self.set
  #     ['etching', 'etching (black)', 'etching (sepia)', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint']
  #   end
  # end

  # module Relief
  #   def self.set
  #     ['relief', 'linocut', 'woodblock print', 'block print']
  #   end
  # end

  # module Poster
  #   def self.set
  #     ['poster', 'vintage poster']
  #   end
  # end

  # module PhotographyPaper
  #   def self.set
  #     ['photograph', 'photolithograph', 'archival photograph', 'single exposure photograph']
  #   end
  # end

  # module Sericel
  #   def self.set
  #     ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline']
  #   end
  # end

  # module BasicPrint
  #   def self.set
  #     ['print', 'fine art print', 'vintage style print']
  #   end
  # end

  # module HandEmbellished
  #   def self.set
  #     ['hand embellished', 'hand painted', 'artist embellished']
  #   end
  # end
  #
  # module HandColored
  #   def self.set
  #     ['hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted']
  #   end
  # end
  #
  # module GoldLeaf
  #   def self.set
  #     ['goldleaf', 'hand laid goldleaf']
  #   end
  # end
  #
  # module SilverLeaf
  #   def self.set
  #     ['silverleaf', 'hand laid silverleaf']
  #   end
  # end
  #
  # module HandPulled
  #   def self.set
  #     ['hand pulled']
  #   end
  # end
