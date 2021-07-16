class Animation
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {Disclaimer: [[:FieldSet, :StandardDisclaimer]]}
  end

  class Sericel < Animation
    def self.assocs
      {
        Category: [[:RadioButton, :ReproductionPrint], [:FieldSet, :LimitedEdition]],
        Medium: [[:SelectField, :StandardSericel]]
      }
    end

    class StandardSericel < Sericel
      def self.assocs
        {
          Authentication: [[:FieldSet, :StandardSericelAuthentication]]
        }
      end
    end

    class BasicSericel < Sericel
      def self.product_name
        'Basic'
      end

      def self.assocs
        {Authentication: [[:FieldSet, :SericelAuthentication]]}
      end
    end
  end

  class WarnerBrosEtching < Animation
    def self.product_name
      'Warner Bros'
    end

    def self.assocs
      {
        Category: [[:FieldSet, :LimitedEdition]],
        Medium: [[:SelectField, :StandardEtching]],
        Signature: [[:SelectField, :StandardSignature]],
        Certificate: [[:SelectField, :StandardCertificate]]
      }
    end
  end

  class ProductionArt < Animation
    def self.assocs
      {Category: [[:RadioButton, :StandardOriginal]], Authentication: [[:FieldSet, :StandardAuthentication]]}
    end

    class ProductionCel < ProductionArt
      def self.assocs
        {Medium: [[:SelectField, :ProductionCel]]}
      end
    end

    class ProductionDrawing < ProductionArt
      def self.assocs
        {
          Medium: [[:SelectField, :ProductionDrawing]],
          Material: [[:FieldSet, :AnimationPaper]]
        }
      end
    end
  end
end
