class Category
  include Context

  class OneOfAKind < Category
  end

  class UniqueVariation < Category
  end

  class LimitedEdition < Category
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['limited edition', 'sold out limited edition']
      end
    end
  end
  class HandMade < Category
  end

  class HandBlownGlass < Category
  end

  class UniqueVariation < Category
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['unique variation']
      end
    end
  end

end
