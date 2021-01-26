module PRD
  extend Build

  # module Painting
  #   def self.opts
  #     {
  #       StandardPainting: {
  #         key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardPainting]],
  #         FGO: [[:FGO, :Material, :Standard]],
  #         FGS: [[:FGS, :Authentication, :Standard]]
  #       },
  #
  #       PaintingOnPaper: {
  #         key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :PaintingOnPaper], [:FieldSet, :Material, :Paper]],
  #         FGS: [[:FGS, :Authentication, :Standard]]
  #       }
  #     }
  #   end
  # end
  #
  # module Drawing
  #   def self.opts
  #     {
  #       StandardDrawing: {
  #         key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardDrawing], [:FieldSet, :Material, :Paper]],
  #         FGS: [[:FGS, :Authentication, :Standard]]
  #       },
  #
  #       MixedMediaDrawing: {
  #         key_group: [[:RadioButton, :Category, :Original], [:SelectField, :Medium, :StandardDrawing], [:FieldSet, :Material, :Paper]],
  #         FGS: [[:FGS, :Submedia, :ForDrawing], [:FGS, :Authentication, :Standard]]
  #       }
  #     }
  #   end
  # end

  module MixedMedia
    def self.opts
      {
        # AcrylicMixedMedia: {
        #   key_group: [[:RadioButton, :Category, :OneOfAKind], [:SelectField, :Medium, :AcrylicMixedMedia]],
        #   FGO: [[:FGO, :Material, :Paper_Canvas]],
        #   FGS: [[:FGS, :Authentication, :Standard]]
        # },
        #
        # PeterMaxAcrylicMixedMedia: {
        #   key_group: [[:RadioButton, :Category, :OneOfAKind], [:SelectField, :Medium, :AcrylicMixedMedia]],
        #   FGS: [[:FGS, :Authentication, :PeterMax]]
        # },

        BrittoMixedMedia: {
          FGO: [[:FGO, :Category, :Original_OneOfAKind], [:FGO, :Material, :Paper_Canvas_Board]],
          key_group: [[:SelectField, :Medium, :BasicMixedMedia]],
          FGS: [[:FGS, :Authentication, :Britto]]
        }

        # Monotype: {
        #   FGO: [[:FGO, :Category, :Original_OneOfAKind]],
        #   key_group: [[:FieldSet, :Material, :Paper], [:SelectField, :Numbering, :OneOfOneNumbering]],
        #   FGS: [[:FGS, :Authentication, :Standard]]
        # }
      }
    end
  end

  # module PrintMedia
  #   def self.opts
  #     {
  #       StandardReproduction: {
  #         key_group: [[:RadioButton, :Category, :Reproduction]],
  #         FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Standard]],
  #         FGS: [[:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       ReproductionOnPaper: {
  #         key_group: [[:RadioButton, :Category, :Reproduction], [:FieldSet, :Material, :Paper]],
  #         FGO: [[:FGO, :PrintMedium, :OnPaper]],
  #         FGS: [[:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       ReproductionOnCanvas: {
  #         key_group: [[:RadioButton, :Category, :Reproduction]],
  #         FGO: [[:FGO, :PrintMedium, :OnPaper], [:FGO, :Material, :Canvas]],
  #         FGS: [[:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       StandardLimitedEdition: {
  #         FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Standard]],
  #         FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       LimitedEditionOnCanvas: {
  #         FGO: [[:FGO, :PrintMedium, :Standard], [:FGO, :Material, :Canvas]],
  #         FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :Standard], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       LimitedEditionOnPaper: {
  #         key_group: [[:FieldSet, :Material, :Paper]],
  #         FGO: [[:FGO, :PrintMedium, :OnPaper]],
  #         FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Submedia, :OnPaper], [:FGS, :Authentication, :Standard]]
  #       },
  #
  #       EverhartLimitedEdition: {
  #         key_group: [[:SelectField, :Medium, :HandPulledLithograph], [:FieldSet, :Material, :Paper], [:RadioButton, :TextBeforeCOA, :Everhart]],
  #         FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :Standard]]
  #       }
  #     }
  #   end
  # end

end
