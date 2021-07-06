class SculptureArt
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.assocs
    {
      SculptureType: end_keys(:SelectField, :Bowl, :Vase, :Sculpture),
      Authentication: [[:FieldSet, :StandardAuthentication]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end

  class StandardSculpture < SculptureArt
    def self.assocs
      {
        Category: [[:RadioButton, :StandardSculpture]],
        Embellishing: [[:SelectField, :StandardEmbellishing]],
        Medium: end_keys(:SelectField, :AcrylicSculpture, :GlassSculpture, :PewterSculpture, :PorcelainSculpture, :ResinSculpture, :MixedMediaSculpture),
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
        {Category: [[:RadioButton, :StandardSculpture]], Medium: [[:SelectField, :HandMadeCeramic]]}
      end
    end

    class HandBlownGlass < HandMadeSculpture
      def self.assocs
        {Category: [[:RadioButton, :StandardHandBlownGlass]], Medium: [[:SelectField, :HandBlownGlass]]}
      end
    end
  end
end
