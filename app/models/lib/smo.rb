module SMO
  extend Build

  module Dimension
    def self.opts
      {
        #FlatDimension: [[:FieldSet, :Dimension, :WidthHeight], [:NumberField, :Dimension, :Diameter]],
        FlatDimension: [[:FieldSet, :Dimension, :WidthHeight], [:FieldSet, :Dimension, :Diameter]],
        DepthDimension: [[:FieldSet, :Dimension, :WidthHeightDepthWeight], [:FieldSet, :Dimension, :DiameterHeightWeight], [:FieldSet, :Dimension, :DiameterWeight]]
      }
    end
  end

  module Mounting
    def self.opts
      {
        StandardMounting: [[:FieldSet, :Mounting, :Framing], [:FieldSet, :Mounting, :Border], [:FieldSet, :Mounting, :Matting]],
        CanvasMounting: [[:FieldSet, :Mounting, :Framing], [:FieldSet, :Mounting, :Matting]],
        SericelMounting: [[:FieldSet, :Mounting, :Framing], [:FieldSet, :Mounting, :Matting]]
      }
    end
  end

  module Numbering
    def self.opts
      {
        #Numbering: [[:FieldSet, :Numbering, :StandardNumbering], [:FieldSet, :Numbering, :RomanNumbering], [:SelectField, :Numbering, :ProofEdition]]
        Numbering: [[:FieldSet, :Numbering, :StandardNumbering], [:FieldSet, :Numbering, :RomanNumbering], [:FieldSet, :Numbering, :ProofEdition]]
      }
    end
  end

end
