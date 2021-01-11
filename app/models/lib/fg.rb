module FG

  module Authentication
    def self.opts
      {
        Standard: [SFO::Signature.opts[:StandardSignature], SFO::Certificate.opts[:StandardCertificate]]
      }
    end
  end

  module Submedia
    def self.opts
      {
        StandardSubmedia: [SFO::Embellished.opts[:StandardEmbellished], SFO::Leafing.opts[:Leafing]],
        SubmediaOnPaper: [SFO::Embellished.opts[:EmbellishedOnPaper], SFO::Leafing.opts[:Leafing], SFO::Remarque.opts[:Remarque]],
        DrawingSubmedia: [SFO::Embellished.opts[:EmbellishedOnPaper], SFO::Leafing.opts[:Leafing]]
      }
    end
  end

end
