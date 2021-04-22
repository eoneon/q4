module TF

  module Date
    def self.opts
      {
        Dated: %w[dated]
      }
    end
  end

  module Numbering
    def self.opts
      {
        Edition: %w[edition],
        EditionSize: %w[edition_size]
      }
    end
  end
end
