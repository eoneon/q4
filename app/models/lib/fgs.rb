module FGS

  module Edition
    def self.opts
      {
        SingleEdition: [[:RadioButton, :Category, :OneOfOne], [:SelectField, :Numbering, :OneOfOneNumbering]],
        LimitedEdition: [[:RadioButton, :Category, :LimitedEdition], [:SelectField, :Edition, :LimitedEdition], [:SelectMenu, :Numbering, :Numbering]],
        UniqueVariation: [[:RadioButton, :Category, :UniqueVariation], [:SelectMenu, :Numbering, :Numbering]]
      }
    end
  end

  module Authentication
    def self.opts
      {
        Standard: [[:SelectField, :Signature, :StandardSignature], [:SelectField, :Certificate, :StandardCertificate]],
        PeterMax: [[:SelectField, :Signature, :StandardSignature], [:SelectField, :Certificate, :PeterMaxCertificate]],
        Britto: [[:SelectField, :Signature, :StandardSignature], [:SelectField, :Certificate, :BrittoCertificate]]
      }
    end
  end

  module Submedia
    def self.opts
      {
        Standard: [[:SelectField, :Embellished, :StandardEmbellished], [:SelectField, :Leafing, :Leafing]],
        OnPaper: [[:SelectField, :Embellished, :EmbellishedOnPaper], [:SelectField, :Leafing, :Leafing], [:SelectField, :Remarque, :Remarque]],
        ForDrawing: [[:SelectField, :Embellished, :EmbellishedOnPaper], [:SelectField, :Leafing, :Leafing]]
      }
    end
  end

end
