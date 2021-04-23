module SFO
  extend Build

  module Medium
    def self.opts
      {
        StandardPainting: [[:Option, :Medium, :StandardPainting]],
        PaintingOnPaper: [[:Option, :Medium, :PaintingOnPaper]],

        StandardDrawing: [[:Option, :Medium, :StandardDrawing]],
        MixedMediaDrawing: [[:Option, :Medium, :StandardDrawing]],

        Silkscreen: [[:Option, :Medium, :Silkscreen]],
        Giclee: [[:Option, :Medium, :Giclee]],
        Lithograph: [[:Option, :Medium, :Lithograph]],
        Etching: [[:Option, :Medium, :Etching]],
        Relief: [[:Option, :Medium, :Relief]],

        HandPulledSilkscreen: [[:Option, :Medium, :HandPulledSilkscreen]],
        HandPulledLithograph: [[:Option, :Medium, :HandPulledLithograph]],

        BasicMixedMedia: [[:Option, :Medium, :BasicMixedMedia]],
        Monotype: [[:Option, :Medium, :Monotype]],
        Seriolithograph: [[:Option, :Medium, :Seriolithograph]],
        AcrylicMixedMedia: [[:Option, :Medium, :AcrylicMixedMedia]],

        BasicPrint: [[:Option, :Medium, :BasicPrint]],
        Poster: [[:Option, :Medium, :Poster]],

        Photograph: [[:Option, :Medium, :Photograph]],
        SingleExposurePhotograph: [[:Option, :Medium, :SingleExposurePhotograph]],
        SportsPhotograph: [[:Option, :Medium, :SportsPhotograph]],
        ConcertPhotograph: [[:Option, :Medium, :ConcertPhotograph]],
        PressPhotograph: [[:Option, :Medium, :PressPhotograph]],

        Sericel: [[:Option, :Medium, :Sericel]],
        ProductionCel: [[:Option, :Medium, :ProductionCel]],

        #HandBlownGlass: [[:Option, :Medium, :HandBlownGlass]],
        Sculpture: [[:Option, :Medium, :Sculpture]]
      }
    end
  end

  module Embellished
    def self.opts
      {
        EmbellishedOnPaper: [[:Option, :Embellished, :EmbellishedOnPaper]],
        StandardEmbellished: [[:Option, :Embellished, :StandardEmbellished]]
      }
    end
  end

  module Leafing
    def self.opts
      {
        Leafing: [[:Option, :Leafing, :Leafing]]
      }
    end
  end

  module Remarque
    def self.opts
      {
        Remarque: [[:Option, :Remarque, :Remarque]]
      }
    end
  end

  module Material
    def self.opts
      {
        Canvas: [[:Option, :Material, :Canvas]],
        WrappedCanvas: [[:Option, :Material, :WrappedCanvas]],
        Board: [[:Option, :Material, :Board]],

        Paper: [[:Option, :Material, :Paper]],
        PhotoPaper: [[:Option, :Material, :PhotoPaper]],
        AnimaPaper: [[:Option, :Material, :AnimaPaper]],

        Wood: [[:Option, :Material, :Wood]],
        WoodBox: [[:Option, :Material, :WoodBox]],

        Metal: [[:Option, :Material, :Metal]],
        MetalBox: [[:Option, :Material, :MetalBox]],
        Acrylic: [[:Option, :Material, :Acrylic]]
      }
    end
  end

  module SculptureType
    def self.opts
      {
        OpenBowl: [[:Option, :SculptureType, :OpenBowl]],
        OpenVase: [[:Option, :SculptureType, :OpenVase]],
        CoveredBowl: [[:Option, :SculptureType, :CoveredBowl]],
        Decorative: [[:Option, :SculptureType, :Decorative]]
      }
    end
  end

  module Mounting
    def self.opts
      {
        Framing: [[:Option, :Mounting, :Framing]],
        Matting: [[:Option, :Mounting, :Matting]],
        Border: [[:Option, :Mounting, :Border]]
      }
    end
  end

  module Signature
    def self.opts
      {
        StandardSignature: [[:Option, :Signature, :StandardSignature]]
      }
    end
  end

  module Certificate
    def self.opts
      {
        StandardCertificate: [[:Option, :Certificate, :StandardCertificate]],
        PeterMaxCertificate: [[:Option, :Certificate, :PeterMaxCertificate]],
        BrittoCertificate: [[:Option, :Certificate, :BrittoCertificate]]
      }
    end
  end

  module Disclaimer
    def self.opts
      {
        DisclaimerType: [[:Option, :Disclaimer, :DisclaimerType]]
      }
    end
  end

  module Edition
    def self.opts
      {
        LimitedEdition: [[:Option, :Edition, :LimitedEdition]]
      }
    end
  end

  module Numbering
    def self.opts
      {
        StandardNumbering: [[:Option, :Numbering, :StandardNumbering]],
        RomanNumbering: [[:Option, :Numbering, :RomanNumbering]],
        OneOfOneNumbering: [[:Option, :Numbering, :OneOfOneNumbering]],
        ProofEdition: [[:Option, :Numbering, :ProofEdition]]
      }
    end
  end

  module SculptureType
    def self.opts
      {
        OpenBowl: [[:Option, :SculptureType, :OpenBowl]],
        OpenVase: [[:Option, :SculptureType, :OpenVase]],
        CoveredBowl: [[:Option, :SculptureType, :CoveredBowl]],
        CoveredVase: [[:Option, :SculptureType, :CoveredVase]]
      }
    end
  end

  module GartnerBladeLid
    def self.opts
      {
        Lid: [[:Option, :GartnerBladeLid, :Lid]]
      }
    end
  end

  module GartnerBladeSize
    def self.opts
      {
        Size: [[:Option, :GartnerBladeSize, :Size]]
      }
    end
  end

  module GartnerBladeColor
    def self.opts
      {
        Color: [[:Option, :GartnerBladeColor, :Color]]
      }
    end
  end


end
