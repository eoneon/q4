class Category
  include Context

  class Original < Category
    def self.builder
      radio_button(field_class_name)
    end
  end

  class OneOfAKind < Category
    def self.builder
      radio_button(field_class_name)
    end
  end

  class UniqueVariation < Category
    def self.builder
      radio_button(field_class_name)
    end
  end

  class LimitedEdition < Category
    def self.builder
      select_field_group(field_class_name, Option.builder(['limited edition', 'sold out limited edition']))
    end
  end

  class HandMade < Category
    def self.builder
      radio_button(field_class_name)
    end
  end

  class HandBlownGlass < Category
    def self.builder
      radio_button(field_class_name)
    end
  end

end
