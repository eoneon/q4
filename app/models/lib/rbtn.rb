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
        Unique: [[:Option, :Category, :Unique]]
      }
    end
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

  module TextBeforeCOA
    def self.opts
      {
        Everhart: [[:Option, :TextBeforeCOA, :Everhart]]
      }
    end
  end

end
