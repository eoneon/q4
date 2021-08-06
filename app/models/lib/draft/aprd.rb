module APRD
  extend Build

  module MixedMedia
    def self.opts
      {
        PeterMax: {
          key_group: [[:RadioButton, :Category, :PeterMaxOneOfAKind], [:SelectField, :Medium, :AcrylicMixedMedia], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Authentication, :PeterMax]]
        },

        Britto: {
          FGO: [[:FGO, :Category, :BrittoOriginal_OneOfAKind], [:FGO, :Material, :Paper_Canvas_Board]],
          key_group: [[:SelectField, :Medium, :BasicMixedMedia]],
          FGS: [[:FGS, :Authentication, :Britto]]
        }
      }
    end
  end

  module PrintMedia
    def self.opts
      {
        Everhart: {
          key_group: [[:SelectField, :Medium, :HandPulledLithograph], [:FieldSet, :Material, :Paper], [:RadioButton, :TextBeforeCOA, :Everhart]],
          FGS: [[:FGS, :Edition, :EverhartLimitedEdition], [:FGS, :Authentication, :Standard]]
        },

        PeterMax: {
          key_group: [[:SelectField, :Medium, :Lithograph], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Edition, :PeterMaxLimitedEdition], [:FGS, :Authentication, :PeterMax]]
        }
      }
    end
  end
end
