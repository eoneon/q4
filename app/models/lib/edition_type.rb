class EditionType
  module ProofType
    def self.set
      ['', 'AP', 'EA', 'CP', 'GP', 'PP', 'IP', 'HC', 'TC']
    end
  end

  module Numbering
    def self.set
      ['numbered', 'Roman numbered', 'Japanese numbered']
    end
  end

  module SingleEdition
    def self.set
      ['1/1']
    end
  end
end
