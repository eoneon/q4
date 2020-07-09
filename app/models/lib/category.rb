class Category
  include Context

  def self.tags
    tags_hsh(0,-1)
  end

  class OriginalMedia < Category
    def self.tags
      tags_hsh(0,1)
    end

    class Original < OriginalMedia
      def self.builder
        radio_button(field_class_name, field_kind, tags)
      end
    end

    class OriginalProduction < OriginalMedia
      def self.builder
        radio_button(field_class_name, field_kind, tags)
      end
    end

    class OneOfAKind < OriginalMedia
      def self.builder
        radio_button(decamelize(klass_name, '-'), field_kind, tags)
      end
    end
  end

  class UniqueVariation < Category
    def self.builder
      select_field(field_class_name, field_kind, options, tags)
    end

    def self.options
      Option.builder([field_class_name], field_kind, tags)
    end
  end

  class LimitedEdition < Category
    def self.builder
      select_field(field_class_name, field_kind, options, tags)
    end

    def self.options
      Option.builder(['limited edition', 'sold out limited edition'], field_kind, tags)
    end
  end

  class HandMadeCeramic < Category
    def self.builder
      select_field(field_class_name, field_kind, options, tags)
    end

    def self.options
      Option.builder([field_class_name], field_kind, tags)
    end
  end

  class HandBlownGlass < Category
    def self.builder
      select_field(field_class_name, field_kind, options, tags)
    end

    def self.options
      Option.builder([field_class_name], field_kind, tags)
    end
  end

end
