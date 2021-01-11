module OPT
  extend Build

  module Category
    def self.opts
      {
        Original: ['original'],
        OneOfAKind: ['one-of-a-kind'],
        UniqueVariation: ['unique variation'],
        LimitedEdition: ['limited edition'],
        Reproduction: ['reproduction'],
        Unique: ['unique']
      }
    end
  end

  module Medium
    def self.opts
      {
        StandardPainting: ['oil painting', 'acrylic painting', 'mixed media painting', 'painting'],
        PaintingOnPaper: ['watercolor painting', 'pastel painting', 'guache painting', 'sumi ink painting', 'oil painting', 'acrylic painting', 'mixed media painting', 'painting'],

        StandardDrawing: ['pen and ink drawing', 'pen and ink sketch', 'pen and ink study', 'pencil drawing', 'pencil sketch', 'colored pencil drawing', 'charcoal drawing', 'wax crayon drawing'],

        Silkscreen: ['serigraph', 'original serigraph', 'silkscreen'],
        Giclee: ['giclee', 'textured giclee'],
        Lithograph: ['lithograph', 'offset lithograph', 'original lithograph'],
        Etching: ['etching', 'etching (black)', 'etching (sepia)', 'hand pulled etching', 'drypoint etching', 'colograph', 'mezzotint', 'aquatint'],
        Relief: ['relief', 'mixed media relief', 'linocut', 'woodblock print', 'block print'],

        HandPulledSilkscreen: ['hand pulled serigraph', 'hand pulled original serigraph', 'hand pulled silkscreen'],
        HandPulledLithograph: ['hand pulled lithograph', 'hand pulled original lithograph'],

        BasicMixedMedia: ['mixed media'],
        Monotype: ['monotype', 'monoprint'],
        Seriolithograph: ['seriolithograph'],
        AcrylicMixedMedia: ['acrylic mixed media'],

        BasicPrint: ['print', 'fine art print', 'vintage style print'],
        Poster: ['poster', 'vintage poster', 'concert poster'],

        Photograph: ['photograph'],
        SingleExposurePhotograph: ['single exposure photograph'],
        SportsPhotograph: ['photograph', 'archival sports photograph'],
        ConcertPhotograph: ['photograph', 'concert photograph', 'archival concert photograph'],
        PressPhotograph: ['vintage press photograph'],

        Sericel: ['sericel', 'hand painted sericel', 'hand painted sericel on serigraph outline'],
        ProductionCel: ['original production cel', 'original production cel and matching drawing', 'original production cel and two matching drawings', 'original production cel and three matching drawings'],

        HandBlownGlass: ['hand blown glass'],
        Sculpture: ['glass', 'ceramic', 'bronze', 'acrylic', 'lucite', 'resin', 'pewter', 'mixed media']
      }
    end
  end

  module Embellished
    def self.opts
      {
        EmbellishedOnPaper: ['hand embellished', 'hand painted', 'hand colored', 'hand watercolored', 'hand colored (pencil)', 'hand tinted'],
        StandardEmbellished: ['hand embellished', 'hand painted', 'artist embellished']
      }
    end
  end

  module Leafing
    def self.opts
      {
        Leafing: ['gold leaf', 'hand laid gold leaf', 'silver leaf', 'hand laid silver leaf', 'hand laid gold and silver leaf', 'hand laid copper leaf']
      }
    end
  end

  module Remarque
    def self.opts
      {
        Remarque: ['remarque', 'hand drawn remarque', 'hand colored remarque', 'hand drawn and colored remarque']
      }
    end
  end

  module Material
    def self.opts
      {
        Canvas: ['canvas', 'canvas board', 'textured canvas'],
        WrappedCanvas: ['gallery wrapped canvas', 'stretched canvas'],

        Paper: ['paper', 'deckle edge paper', 'rice paper', 'arches paper', 'archival paper', 'museum quality paper', 'sommerset paper', 'mother of pearl paper'],
        PhotoPaper: ['paper', 'photography paper', 'archival grade paper'],
        AnimaPaper: ['paper', 'animation paper'],

        Wood: ['wood', 'wood panel', 'board', 'panel'],
        WoodBox: ['wood box'],

        Metal: ['metal', 'metal panel', 'aluminum', 'aluminum panel'],
        MetalBox: ['metal box'],
        Acrylic: ['acrylic', 'acrylic panel', 'resin']
      }
    end
  end

  module SculptureType
    def self.opts
      {
        Decorative: ['bowl', 'vase', 'platter', 'sculpture']
        #GartnerBlade: ['Saturn Oil Lamp', 'Ikebana Flower Bowl', 'Primitive Bowl', 'Primitive Shell', 'Sphere']
      }
    end
  end

  module Mounting
    def self.opts
      {
        Framing: ['framed', 'custom framed', 'box frame', 'simple box frame'],
        Matting: ['matted'],
        Border: ['border', 'oversized border']
      }
    end
  end

  module Signature
    def self.opts
      {
        StandardSignature: ['hand signed', 'plate signed', 'authorized signature', 'estate signed', 'unsigned']
      }
    end
  end

  module Certificate
    def self.opts
      {
        StandardCertificate: ['LOA', 'COA'],
        PeterMaxCertificate: ['LOA', 'COA from Peter Max Studios']
      }
    end
  end

  module Disclaimer
    def self.opts
      {
        DisclaimerType: %w[warning danger]
      }
    end
  end

  module Edition
    def self.opts
      {
        LimitedEdition: ['limited edition', 'sold out limited edition', 'rare limited edition']
      }
    end
  end

  module Numbering
    def self.editions
      [nil, 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC']
    end

    def self.indefinite_article(noun)
      %w[a e i o u].include?(noun.first.downcase) && noun.split('-').first != 'one' || noun == 'HC' ? 'an' : 'a'
    end

    def self.opts
      {
        StandardNumbering: editions.map{|i| [i, 'numbered'].compact.join(' ')},
        RomanNumbering: editions.map{|i| [i, 'Roman numbered'].compact.join(' ')},
        OneOfOneNumbering: editions.map{|i| [i, 'numbered 1/1'].compact.join(' ')},
        ProofEdition: editions.compact.map{|i| ['from', indefinite_article(i), i, 'edition'].join(' ')},
        BatchEdition: ['from an edition of']
        #OpenEdition: ['from an open edition']
      }
    end
  end
end
