module RBTN

  module Category
    def self.opts
      {
        Original: [[:Option, :Category, :Original]],
        BrittoOriginal: [[:Option, :Category, :Original]],
        OneOfAKind: [[:Option, :Category, :OneOfAKind]],
        PeterMaxOneOfAKind: [[:Option, :Category, :OneOfAKind]],
        BrittoOneOfAKind: [[:Option, :Category, :OneOfAKind]],
        OneOfOne: [[:Option, :Category, :OneOfAKind]],
        Production: [[:Option, :Category, :Production]],

        UniqueVariation: [[:Option, :Category, :UniqueVariation]],
        LimitedEdition: [[:Option, :Category, :LimitedEdition]],
        PeterMaxLimitedEdition: [[:Option, :Category, :LimitedEdition]],
        EverhartLimitedEdition: [[:Option, :Category, :LimitedEdition]],
        BatchEdition: [[:Option, :Category, :LimitedEdition]],

        Reproduction: [[:Option, :Category, :Reproduction]],
        HandBlownGlass: [[:Option, :Category, :HandBlownGlass]],
        GartnerBladeGlass: [[:Option, :Category, :HandBlownGlass]]
      }
    end
  end

  module GartnerBladeSculpture
    def self.opts
      {
        Ikebana: [[:Option, :GartnerBladeSculpture, :Ikebana]],

        PrimitiveBowl: [[:Option, :GartnerBladeSculpture, :PrimitiveBowl]],
        PrimitiveShell: [[:Option, :GartnerBladeSculpture, :PrimitiveShell]],

        SaturnLamp: [[:Option, :GartnerBladeSculpture, :SaturnLamp]],
        Arbor: [[:Option, :GartnerBladeSculpture, :Arbor]]
      }
    end
  end

  module GartnerBladeMedium
    def self.opts
      {
        Ikebana: [[:Option, :GartnerBladeMedium, :Ikebana]],
        Primitive: [[:Option, :GartnerBladeMedium, :Primitive]],
        SaturnLamp: [[:Option, :GartnerBladeMedium, :SaturnLamp]],
        Arbor: [[:Option, :GartnerBladeMedium, :Arbor]],
        OpenBowlVase: [[:Option, :GartnerBladeMedium, :OpenBowlVase]],
        CoveredBowlVase: [[:Option, :GartnerBladeMedium, :CoveredBowlVase]]
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
