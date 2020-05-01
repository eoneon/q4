class MountingType
  module Framed
    def self.set
      ['framed', 'custom framed']
    end
  end

  module Border
    def self.set
      ['bordered']
    end
  end

  module Matting
    def self.set
      ['matting']
    end
  end

  module Case
    def self.set
      ['case']
    end
  end

  module Stand
    def self.set
      ['stand']
    end
  end

end
