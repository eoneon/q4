module RBTN
  extend Build

  module Category
    def self.opts
      {
        Original: [[:Option, :Category, :Original]],
        BrittoOriginal: [[:Option, :Category, :Original]],
        OneOfAKind: [[:Option, :Category, :OneOfAKind]],
        PeterMaxOneOfAKind: [[:Option, :Category, :OneOfAKind]],
        BrittoOneOfAKind: [[:Option, :Category, :OneOfAKind]],
        OneOfAKindOfOne: [[:Option, :Category, :OneOfAKind]],
        Production: [[:Option, :Category, :Production]],

        UniqueVariation: [[:Option, :Category, :UniqueVariation]],
        LimitedEdition: [[:Option, :Category, :LimitedEdition]],
        PeterMaxLimitedEdition: [[:Option, :Category, :LimitedEdition]],
        EverhartLimitedEdition: [[:Option, :Category, :LimitedEdition]],
        #BatchLimitedEdition: [[:Option, :Category, :LimitedEdition]],
        Reproduction: [[:Option, :Category, :Reproduction]],
        HandBlownGlass: [[:Option, :Category, :HandBlownGlass]],
        GartnerBladeHandBlownGlass: [[:Option, :Category, :HandBlownGlass]]
      }
    end
  end

  module Medium
    def self.opts
      {
        HandBlownGlass: [[:Option, :Medium, :HandBlownGlass]]
        #GartnerBlade: [[:Option, :Medium, :HandBlownGlass]]
      }
    end
  end

  module SculptureType
    def self.opts
      {
        CoveredVase: [[:Option, :SculptureType, :CoveredVase]],
        PrimitiveBowl: [[:Option, :SculptureType, :PrimitiveBowl]],
        PrimitiveShell: [[:Option, :SculptureType, :PrimitiveShell]],
        Ikebana: [[:Option, :SculptureType, :Ikebana]],
        SaturnLamp: [[:Option, :SculptureType, :SaturnLamp]],
        Arbor: [[:Option, :SculptureType, :Arbor]],
        Sculpture: [[:Option, :SculptureType, :Sculpture]]
      }
    end
  end

  module TextAfterTitle
    def self.opts
      {
        Ikebana: [[:Option, :TextAfterTitle, :Ikebana]],
        Primitive: [[:Option, :TextAfterTitle, :Primitive]],
        SaturnLamp: [[:Option, :TextAfterTitle, :SaturnLamp]],
        Arbor: [[:Option, :TextAfterTitle, :Arbor]],
        OpenBowlVase: [[:Option, :TextAfterTitle, :OpenBowlVase]],
        CoveredBowlVase: [[:Option, :TextAfterTitle, :CoveredBowlVase]]
      }
    end
  end

  module TextBeforeCOA
    def self.opts
      {
        Everhart: [[:Option, :TextBeforeCOA, :Everhart]],
        SingleExposure: [[:Option, :TextBeforeCOA, :SingleExposure]]
      }
    end
  end

end
