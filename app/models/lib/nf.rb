module NF
  extend Build

  module Numbering
    def self.opts
      {
        Edition: %w[edition],
        EditionSize: %w[edition_size]
      }
    end
  end

  module Dimension
    def self.opts
      {
        Width: %w[width],
        Height: %w[height],
        MountingWidth: %w[mounting_width],
        MountingHeight: %w[mounting_height],
        Diameter: %w[diameter],
        Depth: %w[depth],
        Weight: %w[weight]
      }
    end
  end
end


# module Dimension
#   def self.opts
#     {
#       WidthHeight: %w[width height],
#       Diameter: %w[image-diameter],
#       WidthHeightDepth: %w[width height depth],
#
#       WidthHeightDepthWeight: %w[width height depth weight],
#       DiameterHeightWeight: %w[diameter height weight],
#       DiameterWeight: %w[diameter weight]
#     }
#   end
# end
