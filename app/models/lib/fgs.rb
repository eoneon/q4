module FGS

  module Authentication
    def self.opts
      {
        Standard: [[:SelectField, :Signature, :StandardSignature], [:SelectField, :Certificate, :StandardCertificate]],
        PeterMax: [[:SelectField, :Signature, :StandardSignature], [:SelectField, :Certificate, :PeterMaxCertificate]]
      }
    end
  end

  module Submedia
    def self.opts
      {
        Standard: [[:SelectField, :Embellished, :StandardEmbellished], [:SelectField, :Leafing, :Leafing]],
        OnPaper: [[:SelectField, :Embellished, :EmbellishedOnPaper], [:SelectField, :Leafing, :Leafing], [:SelectField, :Remarque, :Remarque]],
        ForDrawing: [[:SelectField, :Embellished, :StandardEmbellished], [:SelectField, :Leafing, :Leafing]]
      }
    end
  end

end

# FG::Submedia.opts[:StandardSubmedia]
