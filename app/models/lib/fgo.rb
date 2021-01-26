module FGO
  extend Build

  module Category
    def self.opts
      {
        Original_OneOfAKind: FGO.build_key_group([:Original, :OneOfAKind], :RadioButton, :Category)
      }
    end
  end

  module Material
    def self.opts
      {
        Standard: FGO.build_key_group([:Canvas, :WrappedCanvas, :Wood, :WoodBox, :Metal, :MetalBox, :Acrylic], :FieldSet, :Material),
        Canvas: FGO.build_key_group([:Canvas, :WrappedCanvas], :FieldSet, :Material),
        Paper_Canvas: FGO.build_key_group([:Canvas, :WrappedCanvas, :Paper], :FieldSet, :Material),
        Paper_Canvas_Board: FGO.build_key_group([:Canvas, :WrappedCanvas, :Paper, :Board], :FieldSet, :Material)
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

  module PrintMedium
    def self.opts
      {
        Standard: FGO.build_key_group([:Silkscreen, :Giclee, :BasicMixedMedia], :SelectField, :Medium),
        OnCanvas: FGO.build_key_group([:Silkscreen, :Giclee, :BasicMixedMedia, :Seriolithograph], :SelectField, :Medium),
        OnPaper: FGO.build_key_group([:Silkscreen, :Lithograph, :Etching, :Relief, :Giclee, :BasicMixedMedia, :Poster, :Seriolithograph], :SelectField, :Medium),
        BasicOnPaper: FGO.build_key_group([:BasicPrint, :Poster], :SelectField, :Medium),
        MixedMediaOnPaper: FGO.build_key_group([:Silkscreen, :HandPulledSilkscreen, :Etching, :Relief], :SelectField, :Medium)
      }
    end
  end

end
