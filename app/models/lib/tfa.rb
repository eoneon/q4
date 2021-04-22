module TFA

  module Disclaimer
    def self.opts
      {
        Disclaimer: %w[disclaimer]
      }
    end
  end

  module Detail
    def self.opts
      {
        BeforeMedia: %w[before_media],
        AfterMedia: %w[after_media],
        AfterBody: %w[after_body]
      }
    end
  end
end
