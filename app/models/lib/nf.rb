module NF

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
