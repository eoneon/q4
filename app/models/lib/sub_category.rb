class SubCategory
  include Context

  class Production < SubCategory
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['production'], search_hsh)
    end
  end

  class HandPulled < SubCategory
    def self.builder
      select_field(field_class_name, options, search_hsh)
    end

    def self.options
      Option.builder(['hand pulled'], search_hsh)
    end
  end
end
