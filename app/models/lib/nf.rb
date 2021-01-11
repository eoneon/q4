module NF

  module Numbering
    def self.opts
      {
        StandardNumbering: %w[edition edition_size],
        BatchEdition: %w[edition_size]
      }
    end
  end

  module Dimension
    def self.opts
      {
        WidthHeight: %w[width height],
        Image_Diameter: %w[image-diameter],
        
        WidthHeightDepth: %w[width height depth],

        WidthHeightDepthWeight: %w[width height depth weight],
        DiameterHeightWeight: %w[diameter height weight],
        DiameterWeight: %w[diameter weight]
      }
    end
  end
end
