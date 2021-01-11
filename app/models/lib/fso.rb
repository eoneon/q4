module FSO

  module Material
    def self.opts
      {
        Canvas: [SFO::Material.opts[:Canvas], FSO::Dimension.opts[:WidthHeight], SMO::Mounting.opts[:CanvasMounting]],
        WrappedCanvas: [SFO::Material.opts[:WrappedCanvas], FSO::Dimension.opts[:WidthHeightDepth]],

        Wood: [SFO::Material.opts[:Wood], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]],
        WoodBox: [SFO::Material.opts[:WoodBox], FSO::Dimension.opts[:WidthHeight]],

        Metal: [SFO::Material.opts[:Metal], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]],
        MetalBox: [SFO::Material.opts[:MetalBox], FSO::Dimension.opts[:WidthHeight]],

        Paper: [SFO::Material.opts[:Paper], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]],
        PhotoPaper: [SFO::Material.opts[:PhotoPaper], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]],
        AnimaPaper: [SFO::Material.opts[:AnimaPaper], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]],

        Acrylic: [SFO::Material.opts[:Acrylic], SMO::Dimension.opts[:FlatDimension], SMO::Mounting.opts[:StandardMounting]]
      }
    end
  end

  module Dimension
    def self.opts
      {
        FlatDimension: [:WidthHeight, :Image_Diameter].map{|k| NF::Dimension.opts[k]},
        BoxDimension: NF::Dimension.opts[:WidthHeightDepth],
        WidthHeight: NF::Dimension.opts[:WidthHeight],
        DepthDimension: [:WidthHeightDepthWeight, :DiameterHeightWeight, :DiameterWeight].map {|k| NF::Dimension.opts[k]}
      }
    end
  end

  module Mounting
    def self.opts
      {
        Framing: [SFO::Mounting.opts[:Framing], NF::Dimension.opts[:WidthHeight]],
        Border: [SFO::Mounting.opts[:Border], NF::Dimension.opts[:WidthHeight]],
        Matting: [SFO::Mounting.opts[:Matting], NF::Dimension.opts[:WidthHeight]]
      }
    end
  end

  module Numbering
    def self.opts
      {
        StandardNumbering: [SFO::Numbering.opts[:StandardNumbering].map{|k| [k, NF::Numbering.opts[:StandardNumbering]].flatten}],
        RomanNumbering: [SFO::Numbering.opts[:RomanNumbering].map{|k| [k, TF::Numbering.opts].flatten}],
        ProofNumbering: SFO::Numbering.opts[:ProofNumbering]
        #BatchEdition: [RBTN::Numbering.opts[:BatchEdition], NF::Numbering.opts[:BatchEdition]]
        #OneOfOneNumbering: SFO::Numbering.opts[:OneOfOneNumbering]
        #OpenEdition: [RBTN::Numbering.opts[:OpenEdition], NF::Numbering.opts[:BatchEdition]]
      }
    end
  end

end

# module Dimension
#   def self.opts
#     {
#       FlatDimension: [:WidthHeight, :Image_Diameter].map {|k| NF::Dimension.opts[k]},
#       BoxDimension: NF::Dimension.opts[:WidthHeightDepth],
#       DepthDimension: [:WidthHeightDepthWeight, :DiameterHeightWeight, :DiameterWeight].map {|k| NF::Dimension.opts[k]},
#       WidthHeight: NF::Dimension.opts[:WidthHeightDepth]
#     }
#   end
# end
