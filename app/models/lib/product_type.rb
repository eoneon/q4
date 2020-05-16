class ProductType
  include Context

  class Painting < ProductType
    def self.builder
      #[Category::Original, Medium::PaintMedia, Material::StandardMaterial]
      #[Category::Original, Medium::PaperSpecificPaintMedia, Material::Paper]
      ProductGroup.builder()
    end
  end

  class Drawing < ProductType
    def self.builder
    end
  end

  class MixedMedia < ProductType
    def self.builder
    end
  end

  # class OneOfAKind < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class UniqueVariationPrint < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class LimitedEditionPrint < ProductType
  #   def self.builder
  #   end
  # end

  class ProductionMedia < ProductType
    def self.builder
    end
  end

  class HandBlownGlass < ProductType
    def self.builder
    end
  end

  class HandMadeCeramic < ProductType
    def self.builder
    end
  end

  class LimitedEditionSculpture < ProductType
    def self.builder
    end
  end

  class Sculpture < ProductType
    def self.builder
    end
  end

  module ProductGroup
    def self.builder
    end
  end
end
