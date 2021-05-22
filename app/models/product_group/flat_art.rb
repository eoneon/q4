class FlatArt
  include ClassContext
  include ProductSeed

  def self.cascade_build(store)
    p_group = build_product_group(store)
  end

  def self.assocs
    {Signature: Signature::StandardSignature, Certificate: Certificate::StandardCertificate, Disclaimer: Disclaimer::Standard}
  end

  ##############################################################################

  class Painting < FlatArt
    def self.assocs
      {Category: Category::StandardOriginal}
    end

    class StandardPainting < Painting
      def self.assocs
        {Medium: Medium::StandardPainting,  Material: Material::Standard}
      end

    end

    class PaintingOnPaper < Painting
      def self.assocs
        {Medium: Medium::PaintingOnPaper, Material: Material::Paper}
      end
    end

  end

  ####################################################

  module Medium
    module StandardPainting
      def self.assocs
        {SelectField: [:OilPainting, :AcylicPainting, :MixedMediaPainting, :UnknownPainting]}
      end
    end

    module PaintingOnPaper
      def self.assocs
        {SelectField: [:WatercolorPainting, :PastelPainting, :GuachePainting]}
      end
    end
  end

  module Category
    module StandardOriginal
      def self.assocs
        {RadioButton: [:StandardOriginal]}
      end
    end
  end

  module Material
    module Standard
      def self.assocs
        {FieldSet: [:StandardCanvas, :WrappedCanvas, :StandardPaper, :StandardBoard, :Wood, :WoodBox, :Acrylic, :StandardMetal, :MetalBox]}
      end
    end

    module Canvas
      def self.assocs
        {FieldSet: [:StandardCanvas]}
      end
    end

    # module CanvasMaterial
    #   def self.assocs
    #     {FieldSet: [:StandardCanvas, :WrappedCanvas]}
    #   end
    # end

    module WrappedCanvas
      def self.assocs
        {FieldSet: [:WrappedCanvas]}
      end
    end

    module Paper
      def self.assocs
        {FieldSet: [:StandardPaper]}
      end
    end

    module PhotoPaper
      def self.assocs
        {FieldSet: [:PhotoPaper]}
      end
    end

    module AnimationPaper
      def self.assocs
        {FieldSet: [:AnimationPaper]}
      end
    end

  end

  module Signature
    module StandardSignature
      def self.assocs
        {SelectField: [:StandardSignature]}
      end
    end
  end

  module Certificate
    module StandardCertificate
      def self.assocs
        {SelectField: [:StandardCertificate]}
      end
    end

    module PeterMaxCertificate
      def self.assocs
        {SelectField: [:PeterMaxCertificate]}
      end
    end

    module BrittoCertificate
      def self.assocs
        {SelectField: [:BrittoCertificate]}
      end
    end
  end

  module Disclaimer
    module Standard
      def self.assocs
        {FieldSet: [:StandardDisclaimer]}
      end
    end
  end


end #end ProductKind
