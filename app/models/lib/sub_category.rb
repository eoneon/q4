class SubCategory
  include Context

  # class Production < SubCategory
  #   def self.builder
  #     radio_button(field_class_name, search_hsh)
  #   end
  # end

  class HandPulled < SubCategory
    def self.builder
      radio_button(field_class_name, search_hsh)
    end
  end
end
