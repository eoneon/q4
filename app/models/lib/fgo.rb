module FGO
  extend Build

  module Material
    def self.opts
      {
        Standard: FGO.build_key_group([:Canvas, :WrappedCanvas, :Wood, :WoodBox, :Metal, :MetalBox, :Acrylic], :FieldSet, :Material),
        Canvas: FGO.build_key_group([:Canvas, :WrappedCanvas], :FieldSet, :Material),
        Paper: FGO.build_key_group([:Paper], :FieldSet, :Material),
        PhotoPaper: FGO.build_key_group([:PhotoPaper], :FieldSet, :Material),
        AnimaPaper: FGO.build_key_group([:AnimaPaper], :FieldSet, :Material)
      }
    end
  end

  module MixedMedia
    def self.opts
      {
        OnPaper: FGO.build_key_group([:AcrylicMixedMedia, :Monotype], :SelectField, :Medium),
        OnCanvas: FGO.build_key_group([:AcrylicMixedMedia, :Monotype], :SelectField, :Medium)
      }
    end
  end

  module PrintMedia
    def self.opts
      {
        Standard: FGO.build_key_group([:Silkscreen, :Giclee, :BasicMixedMedia, :BasicPrint], :SelectField, :Medium),
        OnPaper: FGO.build_key_group([:Silkscreen, :HandPulledSilkscreen, :Lithograph, :HandPulledLithograph, :Giclee, :Seriolithograph, :Etching, :Relief, :BasicMixedMedia, :BasicPrint, :Poster], :SelectField, :Medium),
        HandPulledOnPaper: FGO.build_key_group([:HandPulledSilkscreen, :HandPulledLithograph], :SelectField, :Medium),
        HandPulledOnCanvas: FGO.build_key_group([:HandPulledSilkscreen], :SelectField, :Medium),
        Photograph: FGO.build_key_group([:Photograph, :SingleExposurePhotograph, :SportsPhotograph, :ConcertPhotograph], :SelectField, :Medium)
      }
    end
  end

  # module OriginalMedia
  #   def self.opts
  #     {
  #       Standard: FGO.build_key_group([:AcrylicMixedMedia, :Monotype], :SelectField, :Medium),
  #       OnCanvas: FGO.build_key_group([:AcrylicMixedMedia, :Monotype], :SelectField, :Medium)
  #     }
  #   end
  # end

end
