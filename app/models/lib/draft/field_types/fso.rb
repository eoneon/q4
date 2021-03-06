module FSO
  extend Build
  
  module Dimension
    def self.opts
      {
        WidthHeight: [[:NumberField, :Dimension, :Width], [:NumberField, :Dimension, :Height]],
        MountingWidthHeight: [[:NumberField, :Dimension, :MountingWidth], [:NumberField, :Dimension, :MountingHeight]],
        WidthHeightDepth: [[:NumberField, :Dimension, :Width], [:NumberField, :Dimension, :Height], [:NumberField, :Dimension, :Depth]],
        Diameter: [[:NumberField, :Dimension, :Diameter]],

        WidthHeightDepthWeight: [[:NumberField, :Dimension, :Width], [:NumberField, :Dimension, :Height], [:NumberField, :Dimension, :Depth], [:NumberField, :Dimension, :Weight]],
        DiameterHeightWeight: [[:NumberField, :Dimension, :Diameter], [:NumberField, :Dimension, :Height], [:NumberField, :Dimension, :Weight]],
        DiameterWeight: [[:NumberField, :Dimension, :Diameter], [:NumberField, :Dimension, :Weight]]
      }
    end
  end

  module Mounting
    def self.opts
      {
        Framing: [[:SelectField, :Mounting, :Framing], [:FieldSet, :Dimension, :MountingWidthHeight]],
        Border: [[:SelectField, :Mounting, :Border], [:FieldSet, :Dimension, :MountingWidthHeight]],
        Matting: [[:SelectField, :Mounting, :Matting], [:FieldSet, :Dimension, :MountingWidthHeight]]
      }
    end
  end

  module Material
    def self.opts
      {
        Canvas: [[:SelectField, :Material, :Canvas], [:FieldSet, :Dimension, :WidthHeight], [:SelectMenu, :Mounting, :CanvasMounting]],
        WrappedCanvas: [[:SelectField, :Material, :WrappedCanvas], [:FieldSet, :Dimension, :WidthHeight]],

        Wood: [[:SelectField, :Material, :Wood], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],
        WoodBox: [[:SelectField, :Material, :WoodBox], [:FieldSet, :Dimension, :WidthHeightDepth]],
        Board: [[:SelectField, :Material, :Board], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],

        Metal: [[:SelectField, :Material, :Metal], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],
        MetalBox: [[:SelectField, :Material, :MetalBox], [:FieldSet, :Dimension, :WidthHeightDepth]],

        Paper: [[:SelectField, :Material, :Paper], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],
        PhotoPaper: [[:SelectField, :Material, :PhotoPaper], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],

        AnimaPaper: [[:SelectField, :Material, :AnimaPaper], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]],
        Acrylic: [[:SelectField, :Material, :Acrylic], [:SelectMenu, :Dimension, :FlatDimension], [:SelectMenu, :Mounting, :StandardMounting]]
      }
    end
  end

  module Numbering
    def self.opts
      {
        StandardNumbering: [[:SelectField, :Numbering, :StandardNumbering], [:NumberField, :Numbering, :Edition], [:NumberField, :Numbering, :EditionSize]],
        RomanNumbering: [[:SelectField, :Numbering, :RomanNumbering], [:TextField, :Numbering, :Edition], [:TextField, :Numbering, :EditionSize]],
        ProofEdition: [[:SelectField, :Numbering, :ProofEdition]]
      }
    end
  end

end
