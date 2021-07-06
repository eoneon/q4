class GartnerBlade
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable
  include ProductSeed

  def self.product_name
    class_to_cap(const)
  end

  def self.assocs
    {
      Category: [[:RadioButton, :GartnerBladeGlass]],
      SculptureType: end_keys(:FieldSet, :PrimitiveBowl, :PrimitiveShell, :IkebanaFlowerBowl, :SaturnOilLamp, :ArborSculpture, :OpenBowl, :OpenVase, :CoveredBowl, :CoveredVase),
      Signature: [[:SelectField, :StandardSignature]],
      Disclaimer: [[:FieldSet, :StandardDisclaimer]]
    }
  end
end
