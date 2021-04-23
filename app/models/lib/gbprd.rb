module GBPRD
  extend Build

  # def self.name_keys
  #   %w[product_type category product_subtype]
  # end

  def self.name_keys
    %w[category sculpture_type]
  end

  def self.tag_keys
    [:Category, :SculptureType]
  end

  def self.field_order
    [:GartnerBladeSize, :GartnerBladeColor, :Category, :SculptureType, :GartnerBladeLid, :Medium, :TextAfterTitle, :Signature]
  end

  ##############################################################################

  module GartnerBlade
    def self.opts
      {
        IkebanaFlowerBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:RadioButton, :SculptureType, :Ikebana], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        SaturnOilLamp: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:RadioButton, :SculptureType, :SaturnLamp], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        PrimitiveShell: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:RadioButton, :SculptureType, :PrimitiveShell], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight], [:SelectField, :Signature, :StandardSignature]]
        },

        ArborSculpture: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:RadioButton, :SculptureType, :Arbor], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight], [:SelectField, :Signature, :StandardSignature]]
        },

        OpenBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:SelectField, :SculptureType, :OpenBowl], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        OpenVase: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:SelectField, :SculptureType, :OpenVase], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        CoveredBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:SelectField, :SculptureType, :CoveredBowl], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        },

        CoveredVase: {
          key_group: [[:RadioButton, :Category, :GartnerBladeHandBlownGlass], [:RadioButton, :SculptureType, :CoveredVase], [:RadioButton, :Medium, :HandBlownGlass], [:RadioButton, :TextAfterTitle, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        }
      }
    end
  end
end

# module GartnerBlade
#   def self.opts
#     {
#       Ikebana: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :SculptureType, :Ikebana], [:RadioButton, :TextAfterTitle, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       SaturnLamp: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :SculptureType, :SaturnLamp], [:RadioButton, :TextAfterTitle, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       PrimitiveShell: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :SculptureType, :PrimitiveShell], [:RadioButton, :TextAfterTitle, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#       Arbor: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :SculptureType, :Arbor], [:RadioButton, :TextAfterTitle, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#
#       OpenBowl: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :SculptureType, :Bowl], [:RadioButton, :TextAfterTitle, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       OpenVase: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :SculptureType, :OpenVase], [:RadioButton, :TextAfterTitle, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#
#       CoveredBowl: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :SculptureType, :CoveredBowl], [:RadioButton, :TextAfterTitle, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       CoveredVase: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :SculptureType, :CoveredBowl], [:RadioButton, :TextAfterTitle, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]]
#     }
#   end
# end
