module RBTN
  extend Build

  module Category
    def self.opts
      {
        Original: [:OPT, :Category, :Original],
        OneOfAKind: [:OPT, :Category, :OneOfAKind],
        OneOfOne: [:OPT, :Category, :OneOfAKind],
        UniqueVariation: [:OPT, :Category, :UniqueVariation],
        LimitedEdition: [:OPT, :Category, :LimitedEdition],
        BatchEdition: [:OPT, :Category, :LimitedEdition],
        Reproduction: [:OPT, :Category, :Reproduction],
        Unique: [:OPT, :Category, :Unique]
      }
    end
  end

  # module Category
  #   def self.opts
  #     {
  #       Original: OPT::Category.opts[:Original],
  #       OneOfAKind: OPT::Category.opts[:OneOfAKind],
  #       OneOfOne: OPT::Category.opts[:OneOfAKind],
  #       UniqueVariation: OPT::Category.opts[:UniqueVariation],
  #       LimitedEdition: OPT::Category.opts[:LimitedEdition],
  #       BatchEdition: OPT::Category.opts[:LimitedEdition],
  #       Reproduction: OPT::Category.opts[:Reproduction],
  #       Unique: OPT::Category.opts[:Unique]
  #     }
  #   end
  # end

end
