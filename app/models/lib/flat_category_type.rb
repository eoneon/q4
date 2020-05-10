class FlatCategoryType
  include Context

  class Original < FlatCategoryType
  end

  class OneOfAKind < FlatCategoryType
  end

  class UniqueVariation < FlatCategoryType
  end

  class LimitedEdition < FlatCategoryType
    def self.set
      Options.set
    end

    module Options
      def self.set
        ['limited edition', 'sold out limited edition']
      end
    end
  end

  class Standard < FlatCategoryType
  end

end
