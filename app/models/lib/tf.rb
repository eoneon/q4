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
        RomanEdition: %w[edition edition_size]
      }
    end
  end
end
