module PRD
  extend Build

  module Painting
    def self.opts
      {
        StandardPainting: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardPainting]],
          FGO: [[:FGO, :Material, :Standard]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        PaintingOnPaper: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :PaintingOnPaper], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

  module Drawing
    def self.opts
      {
        StandardDrawing: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardDrawing], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        MixedMediaDrawing: {
          key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardDrawing], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Submedia, :ForDrawing], [:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

  module MixedMedia
    def self.opts
      {
        AcrylicMixedMedia: {
          key_group: [[:RadioButton, :Category, :OneOfAKind], [:SelectField, :Medium, :AcrylicMixedMedia]],
          FGO: [[:FGO, :Material, :Paper_Canvas]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        Monotype: {
          FGO: [[:FGO, :Category, :Original_OneOfAKind]],
          key_group: [[:SelectField, :Medium,:Monotype], [:FieldSet, :Material, :Paper], [:SelectField, :Numbering, :OneOfOneNumbering]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        OneOfAKindOnPaper: {
          key_group: [[:RadioButton, :Category, :OneOfAKind], [:FieldSet, :Material, :Paper]],
          FGO: [[:FGO, :MixedMedia, :Etching_Silkscreen]],
          FGS: [[:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
        },

        OneOfAKindOnCanvas: {
          key_group: [[:RadioButton, :Category, :OneOfAKind]],
          FGO: [[:FGO, :MixedMedia, :Silkscreen], [:FGO, :Material, :Canvas]],
          FGS: [[:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        },

        OneOfOneOnPaper: {
          key_group: [[:FieldSet, :Material, :Paper]],
          FGO: [[:FGO, :MixedMedia, :Etching_Silkscreen]],
          FGS: [[:FGS, :Edition, :SingleEdition], [:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
        },

        OneOfOneOnCanvas: {
          FGO: [[:FGO, :MixedMedia, :Silkscreen], [:FGO, :Material, :Canvas]],
          FGS: [[:FGS, :Edition, :SingleEdition], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

  module PrintMedia
    def self.opts
      {
        StandardReproduction: {
          key_group: [[:RadioButton, :Category, :Reproduction]],
          FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Standard]],
          FGS: [[:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        },

        ReproductionOnPaper: {
          key_group: [[:RadioButton, :Category, :Reproduction], [:FieldSet, :Material, :Paper]],
          FGO: [[:FGO, :PrintMedium, :OnPaper]],
          FGS: [[:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
        },

        ReproductionOnCanvas: {
          key_group: [[:RadioButton, :Category, :Reproduction]],
          FGO: [[:FGO, :PrintMedium, :OnCanvas], [:FGO, :Material, :Canvas]],
          FGS: [[:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        },

        StandardLimitedEdition: {
          FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Standard]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        },

        LimitedEditionOnCanvas: {
          FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Canvas]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        },

        LimitedEditionOnPaper: {
          key_group: [[:FieldSet, :Material, :Paper]],
          FGO: [[:FGO, :PrintMedium, :OnPaper]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
        },

        UniqueVariationOnCanvas: {
          FGO: [[:FGO, :MixedMedia, :Silkscreen], [:FGO, :Material, :Canvas]],
          FGS: [[:FGS, :Edition, :UniqueVariation], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

  module PhotoMedia
    def self.opts
      {
        ReproductionPhotograph: {
          key_group: [[:RadioButton, :Category, :Reproduction], [:SelectField, :Medium, :Photograph], [:FieldSet, :Material, :PhotoPaper]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        LimitedEditionPhotograph: {
          key_group: [[:SelectField, :Medium, :Photograph], [:FieldSet, :Material, :PhotoPaper]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :Standard]]
        },

        LimitedEditionSingleExposure: {
          key_group: [[:SelectField, :Medium, :SingleExposurePhotograph], [:FieldSet, :Material, :PhotoPaper], [:RadioButton, :TextBeforeCOA, :SingleExposure]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

  module Animation
    def self.opts
      {
        ReproductionSericel: {
          key_group: [[:RadioButton, :Category, :Reproduction], [:SelectField, :Medium, :Sericel], [:SelectMenu, :Mounting, :SericelMounting]],
          FGS: [[:FGS, :Authentication, :Standard]]
        },

        LimitedEditionSericel: {
          key_group: [[:SelectField, :Medium, :Sericel], [:SelectMenu, :Mounting, :SericelMounting]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :Standard]]
        }
      }
    end
  end

end
