class Category
  include Context

  class Original < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['original'], search_hsh)
    end
  end

  class OneOfAKind < Category
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['one-of-a-kind'], search_hsh)
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
