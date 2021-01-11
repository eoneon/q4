module SMO

  module Dimension
    def self.opts
      {
        FlatDimension: [:WidthHeight, :Image_Diameter].map {|k| FSO::Dimension.opts[k]}
      }
    end
  end

  module Mounting
    def self.opts
      {
        StandardMounting: [:Framing, :Border, :Matting].map {|k| FSO::Mounting.opts[k]},
        CanvasMounting: [:Framing, :Matting].map {|k| FSO::Mounting.opts[k]},
        SericelMounting: SMO::Dimension.opts[:CanvasMounting]
      }
    end
  end

  module Numbering
    def self.opts
      {
        Numbering: [:StandardNumbering, :RomanNumbering, :ProofNumbering].map{|k| FSO::Numbering.opts[k]}
      }
    end
  end

end
