module RBTN
  extend Build

  module Category
    def self.opts
      {
        Original: [[:Option, :Category, :Original]],
        OneOfAKind: [[:Option, :Category, :OneOfAKind]],
        OneOfOne: [[:Option, :Category, :OneOfAKind]],
        Production: [[:Option, :Category, :Production]],

        UniqueVariation: [[:Option, :Category, :UniqueVariation]],
        LimitedEdition: [[:Option, :Category, :LimitedEdition]],
        BatchEdition: [[:Option, :Category, :LimitedEdition]],

        Reproduction: [[:Option, :Category, :Reproduction]],
        #Unique: [[:Option, :Category, :Unique]],
        HandBlownGlass: [[:Option, :Category, :HandBlownGlass]]
      }
    end
  end

  #each one of these has its own TextBeforeCOA on OPT
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

  # module TextBeforeCOA
  #   def self.opts
  #     {
  #       Everhart: [[:Option, :TextBeforeCOA, :Everhart]],
  #       SingleExposure: [[:Option, :TextBeforeCOA, :SingleExposure]]
  #     }
  #   end
  # end

end

# module Medium
#   def self.opts
#     {
#       BasicMixedMedia: ['mixed media'],
#       Seriolithograph: ['seriolithograph'],
#       AcrylicMixedMedia: ['acrylic mixed media'],
#       EverhartLithograph: ['hand pulled lithograph'],
#       HandBlownGlass: ['hand blown glass']
#     }
#   end
# end
