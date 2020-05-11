class FlatMountingType
  include Context

  class StandardMounting < FlatMountingType
    def self.set
      [Framed, Border, Matting]
    end
  end

  class CanvasMounting < FlatMountingType
    def self.set
      [Framed, Matting]
    end
  end

  class SericelMounting < FlatMountingType
    def self.set
      CanvasMounting.set
    end
  end

  class Framed < FlatMountingType
    def self.set
      ['framed', 'custom framed']
    end
  end

  class Border < FlatMountingType
    def self.set
      ['border']
    end
  end

  class Matting < FlatMountingType
    def self.set
      ['matting']
    end
  end
end
