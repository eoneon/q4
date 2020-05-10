class SculptureCategoryType

  class HandMade < SculptureCategoryType
  end

  class HandBlownGlass < SculptureCategoryType
  end

  class UniqueVariation < SculptureCategoryType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['unique variation']
      end
    end
  end

  class LimitedEdition < SculptureCategoryType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['limited edition', 'sold out limited edition', 'vintage limited edition']
      end
    end
  end

  class Standard < SculptureCategoryType
  end

end
