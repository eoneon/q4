module TFA
  extend Build

  module Disclaimer
    def self.opts
      {
        Disclaimer: %w[disclaimer]
      }
    end
  end
end
