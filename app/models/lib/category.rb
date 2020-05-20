class Category
  include Context

  class OriginalMedia < Category
    class Original < OriginalMedia
      def self.builder
        radio_button(field_class_name, tags_hsh(0,1))
      end
    end

    class OriginalProduction < OriginalMedia
      def self.builder
        radio_button(field_class_name, tags_hsh(0,1))
      end
    end

    class OneOfAKind < OriginalMedia
      def self.builder
        radio_button(decamelize(klass_name, '-'), tags_hsh(0,1))
      end
    end
  end

  class UniqueVariation < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder([field_class_name], search_hsh)
    end
  end

  class LimitedEdition < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['limited edition', 'sold out limited edition'], search_hsh)
    end
  end

  class HandMadeCeramic < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder([field_class_name], search_hsh)
    end
  end

  class HandBlownGlass < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder([field_class_name], search_hsh)
    end
  end

end
