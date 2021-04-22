class Art
  extend ProductBuild
  #Art::Flat::Standard::PRD
  #Art::StandardFlat:PRD
  class StandardFlat < Art
    extend PRD
  end

  class Flat < Art
    #extend PRD
  end
  #Art::Sculpture::GartnerBlade
  class Sculpture < Art
    class GartnerBlade < Sculpture
      extend GBPRD
    end
  end
end
