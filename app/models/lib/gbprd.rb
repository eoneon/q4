module GBPRD
  extend Build

  def self.name_keys
    %w[product_type category product_subtype]
  end

  def self.tag_keys
    [:Category, :GartnerBladeSculpture]
  end

  def self.field_order
    [:GartnerBladeSize, :GartnerBladeColor, :Category, :GartnerBladeSculpture, :GartnerBladeLid, :GartnerBladeMedium, :Signature]
  end

  ##############################################################################

  module GartnerBlade
    def self.opts
      {
        IkebanaFlowerBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :Ikebana], [:RadioButton, :GartnerBladeMedium, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        SaturnOilLamp: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :SaturnLamp], [:RadioButton, :GartnerBladeMedium, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        PrimitiveShell: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :PrimitiveShell], [:RadioButton, :GartnerBladeMedium, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight], [:SelectField, :Signature, :StandardSignature]]
        },

        ArborSculpture: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :Arbor], [:RadioButton, :GartnerBladeMedium, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight], [:SelectField, :Signature, :StandardSignature]]
        },

        OpenBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :OpenBowl], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        OpenVase: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :OpenVase], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        CoveredBowl: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        },

        CoveredVase: {
          key_group: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight], [:SelectField, :Signature, :StandardSignature]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        }
      }
    end
  end
end

# module GartnerBlade
#   def self.opts
#     {
#       Ikebana: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :Ikebana], [:RadioButton, :GartnerBladeMedium, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       SaturnLamp: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :SaturnLamp], [:RadioButton, :GartnerBladeMedium, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       PrimitiveShell: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :PrimitiveShell], [:RadioButton, :GartnerBladeMedium, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#       Arbor: [[:RadioButton, :Category, :GartnerBladeGlass], [:RadioButton, :GartnerBladeSculpture, :Arbor], [:RadioButton, :GartnerBladeMedium, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#
#       OpenBowl: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :Bowl], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       OpenVase: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :OpenVase], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#
#       CoveredBowl: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       CoveredVase: [[:RadioButton, :Category, :GartnerBladeGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]]
#     }
#   end
# end
