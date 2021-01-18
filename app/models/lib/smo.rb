module SMO
  extend Build

  module Dimension
    def self.opts
      {
        #FlatDimension: [[:FieldSet, :Dimension, :WidthHeight], [:FieldSet, :Dimension, :Diameter]],
        FlatDimension: [[:FieldSet, :Dimension, :WidthHeight], [:NumberField, :Dimension, :Diameter]],
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
        Numbering: [[:FieldSet, :Numbering, :StandardNumbering], [:FieldSet, :Numbering, :RomanNumbering], [:SelectField, :Numbering, :ProofEdition]]
      }
    end
  end

end

# module Dimension
#   def self.opts
#     {
#       FlatDimension: [:WidthHeight, :Image_Diameter].map {|k| FSO::Dimension.opts[k]}
#     }
#   end
# end
#
# module Mounting
#   def self.opts
#     {
#       StandardMounting: [:Framing, :Border, :Matting].map {|k| FSO::Mounting.opts[k]},
#       CanvasMounting: [:Framing, :Matting].map {|k| FSO::Mounting.opts[k]},
#       SericelMounting: SMO::Dimension.opts[:CanvasMounting]
#     }
#   end
# end
#
# module Numbering
#   def self.opts
#     {
#       Numbering: [:StandardNumbering, :RomanNumbering, :ProofNumbering].map{|k| FSO::Numbering.opts[k]}
#     }
#   end
# end
