class SculptureArt
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class StandardSculpture < SculptureArt
    def self.assocs
      {
        Embellishing: [[:SelectField, :StandardEmbellishing]],
        SculptureType: end_keys(:FieldSet, :AcrylicSculpture, :GlassSculpture, :PewterSculpture, :PorcelainSculpture, :ResinSculpture, :MixedMediaSculpture)
      }
    end

    class Sculpture < StandardSculpture
      def self.assocs
        {Category: [[:RadioButton, :StandardSculpture]]}
      end
    end

    class LimitedEditionSculpture < StandardSculpture
      def self.assocs
        {Category: [[:FieldSet, :LimitedEditionSculpture]]}
      end
    end
  end

  class HandMadeSculpture < SculptureArt
    class HandMadeCeramic < HandMadeSculpture
      def self.assocs
        {
          Category: [[:RadioButton, :HandMadeCeramic]],
          SculptureType: [[:FieldSet, :HandMadeCeramic]]
        }
      end
    end

    class HandBlownGlass < HandMadeSculpture
      def self.assocs
        {
          Category: [[:RadioButton, :StandardHandBlownGlass]],
          SculptureType: [[:FieldSet, :HandBlownGlass]]
        }
      end
    end
  end
end
