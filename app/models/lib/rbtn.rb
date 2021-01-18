module RBTN
  extend Build

  module Category
    def self.opts
      {
        Original: [[:Option, :Category, :Original]],
        OneOfAKind: [[:Option, :Category, :OneOfAKind]],
        OneOfOne: [[:Option, :Category, :OneOfAKind]],
        UniqueVariation: [[:Option, :Category, :UniqueVariation]],
        LimitedEdition: [[:Option, :Category, :LimitedEdition]],
        BatchEdition: [[:Option, :Category, :LimitedEdition]],
        Reproduction: [[:Option, :Category, :Reproduction]],
        Unique: [[:Option, :Category, :Unique]]
      }
    end
  end

end
