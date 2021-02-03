module APRD
  extend Build
  # a = APRD.seed_products

  def self.name_keys
    %w[product_subtype category medium material]
  end

  ##############################################################################

  module MixedMedia
    def self.opts
      {
        PeterMax: {
          key_group: [[:RadioButton, :Category, :OneOfAKind], [:SelectField, :Medium, :AcrylicMixedMedia], [:FieldSet, :Material, :Paper]],
          FGS: [[:FGS, :Authentication, :PeterMax]]
        },

        Britto: {
          FGO: [[:FGO, :Category, :Original_OneOfAKind], [:FGO, :Material, :Paper_Canvas_Board]],
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
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :Standard]]
        }
      }
    end

    def self.opts
      {
        PeterMax: {
          key_group: [[:SelectField, :Medium, :Lithograph], [:FieldSet, :Material, :Paper], [:RadioButton, :TextBeforeCOA, :Everhart]],
          FGS: [[:FGS, :Edition, :LimitedEdition], [:FGS, :Authentication, :PeterMax]]
        }
      }
    end
  end
end
