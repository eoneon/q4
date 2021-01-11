module SFO

  module Medium
    def self.opts
      {
        StandardPainting: OPT::Medium.opts[:StandardPainting],
        PaintingOnPaper: OPT::Medium.opts[:PaintingOnPaper],

        StandardDrawing: OPT::Medium.opts[:StandardDrawing],

        Silkscreen: OPT::Medium.opts[:Silkscreen],
        Giclee: OPT::Medium.opts[:Giclee],
        Lithograph: OPT::Medium.opts[:Lithograph],
        Etching: OPT::Medium.opts[:Etching],
        Relief: OPT::Medium.opts[:Relief],

        HandPulledSilkscreen: OPT::Medium.opts[:Silkscreen].map{|k| ['hand pulled', k].join(' ')},
        HandPulledLithograph: OPT::Medium.opts[:HandPulledLithograph],

        BasicMixedMedia: OPT::Medium.opts[:BasicMixedMedia],
        Monotype: OPT::Medium.opts[:Monotype],
        Seriolithograph: OPT::Medium.opts[:Seriolithograph],
        AcrylicMixedMedia: OPT::Medium.opts[:AcrylicMixedMedia],

        BasicPrint: OPT::Medium.opts[:BasicPrint],
        Poster: OPT::Medium.opts[:Poster],

        Photograph: OPT::Medium.opts[:Photograph],
        SingleExposurePhotograph: OPT::Medium.opts[:SingleExposurePhotograph],
        SportsPhotograph: OPT::Medium.opts[:SportsPhotograph],
        ConcertPhotograph: OPT::Medium.opts[:ConcertPhotograph],
        PressPhotograph: OPT::Medium.opts[:PressPhotograph],

        Sericel: OPT::Medium.opts[:Sericel],
        ProductionCel: OPT::Medium.opts[:ProductionCel],

        HandBlownGlass: OPT::Medium.opts[:HandBlownGlass],
        Sculpture: OPT::Medium.opts[:Sculpture]
      }
    end
  end

  module Embellished
    def self.opts
      {
        EmbellishedOnPaper: OPT::Embellished.opts[:EmbellishedOnPaper],
        StandardEmbellished: OPT::Embellished.opts[:StandardEmbellished]
      }
    end
  end

  module Leafing
    def self.opts
      {
        Leafing: OPT::Leafing.opts[:Leafing]
      }
    end
  end

  module Remarque
    def self.opts
      {
        Remarque: OPT::Remarque.opts[:Remarque]
      }
    end
  end

  module Material
    def self.opts
      {
        Canvas: OPT::Material.opts[:Canvas],
        WrappedCanvas: OPT::Material.opts[:WrappedCanvas],

        Paper: OPT::Material.opts[:Paper],
        PhotoPaper: OPT::Material.opts[:PhotoPaper],
        AnimaPaper: OPT::Material.opts[:AnimaPaper],

        Wood: OPT::Material.opts[:Wood],
        WoodBox: OPT::Material.opts[:WoodBox],

        Metal: OPT::Material.opts[:Metal],
        MetalBox: OPT::Material.opts[:MetalBox],
        Acrylic: OPT::Material.opts[:Acrylic]
      }
    end
  end

  module SculptureType
    def self.opts
      {
        Decorative: OPT::SculptureType.opts[:Decorative]
        #GartnerBlade: ['Saturn Oil Lamp', 'Ikebana Flower Bowl', 'Primitive Bowl', 'Primitive Shell', 'Sphere']
      }
    end
  end

  module Mounting
    def self.opts
      {
        Framing: OPT::Mounting.opts[:Framing],
        Matting: OPT::Mounting.opts[:Matting],
        Border: OPT::Mounting.opts[:Border]
      }
    end
  end

  module Signature
    def self.opts
      {
        StandardSignature: OPT::Signature.opts[:StandardSignature]
      }
    end
  end

  module Certificate
    def self.opts
      {
        StandardCertificate: OPT::Certificate.opts[:StandardCertificate],
        PeterMaxCertificate: OPT::Certificate.opts[:PeterMaxCertificate]
      }
    end
  end

  module Disclaimer
    def self.opts
      {
        DisclaimerType: OPT::Disclaimer.opts[:DisclaimerType]
      }
    end
  end

  module Edition
    def self.opts
      {
        LimitedEdition: OPT::Edition.opts[:LimitedEdition]
      }
    end
  end

  module Numbering
    def self.opts
      {
        StandardNumbering: OPT::Numbering.opts[:StandardNumbering],
        RomanNumbering: OPT::Numbering.opts[:RomanNumbering],
        OneOfOneNumbering: OPT::Numbering.opts[:OneOfOneNumbering],
        ProofEdition: OPT::Numbering.opts[:ProofEdition]
      }
    end
  end
end
