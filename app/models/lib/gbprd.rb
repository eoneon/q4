module GBPRD
  extend Build

  # def product_name(tags, name_set=[])
  #   %w[product_type category product_subtype].each do |k|
  #     name = k == 'product_type' ? tags[k] : tags[k].underscore.split('_').map{|word| word.capitalize}.join(' ')
  #     name_set << name
  #   end
  #   name_set.join(' ')
  # end

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
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :Ikebana], [:RadioButton, :GartnerBladeMedium, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        SaturnOilLamp: {
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :SaturnLamp], [:RadioButton, :GartnerBladeMedium, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        PrimitiveShell: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :PrimitiveShell], [:RadioButton, :GartnerBladeMedium, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight]]
        },

        ArborSculpture: {
          key_group: [[:SelectField, :GartnerBladeSize, :Size], [:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :Arbor], [:RadioButton, :GartnerBladeMedium, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight]]
        },

        OpenBowl: {
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :OpenBowl], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        OpenVase: {
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :OpenVase], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColor, :SizeColor]]
        },

        CoveredBowl: {
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        },

        CoveredVase: {
          key_group: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
          FGS: [[:FGS, :GartnerBladeSizeColorLid, :SizeColorLid]]
        }
      }
    end
  end
end

# module GartnerBlade
#   def self.opts
#     {
#       Ikebana: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :Ikebana], [:RadioButton, :GartnerBladeMedium, :Ikebana], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       SaturnLamp: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :SaturnLamp], [:RadioButton, :GartnerBladeMedium, :SaturnLamp], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       PrimitiveShell: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :PrimitiveShell], [:RadioButton, :GartnerBladeMedium, :Primitive], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#       Arbor: [[:RadioButton, :Category, :HandBlownGlass], [:RadioButton, :GartnerBladeSculpture, :Arbor], [:RadioButton, :GartnerBladeMedium, :Arbor], [:FieldSet, :Dimension, :WidthHeightDepthWeight]],
#
#       OpenBowl: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :Bowl], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       OpenVase: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :OpenVase], [:RadioButton, :GartnerBladeMedium, :OpenBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#
#       CoveredBowl: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]],
#       CoveredVase: [[:RadioButton, :Category, :HandBlownGlass], [:SelectField, :GartnerBladeSculpture, :CoveredBowl], [:RadioButton, :GartnerBladeMedium, :CoveredBowlVase], [:FieldSet, :Dimension, :DiameterHeightWeight]]
#     }
#   end
# end
