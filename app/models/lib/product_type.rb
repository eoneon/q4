class ProductType

  class Painting < ProductType
    def self.builder
      klass_name = decamelize(self.slice_class(-1))
      options = ['painting', 'oil', 'acrylic', 'mixed media'].map {|opt_name| ['original', opt_name, 'painting'].uniq}
      select_field = Select.field(klass_name, Option.builder(options))
      #SelectMenu.builder(h={field_name: "paint-options", options: [Mounting::Framed.builder, Mounting::Matting.builder]})
    end
  end

  class Painting
    class Painting
      #MediumType::Painting.set -> f method
      #MaterialType::Painting.set
    end

    class PaintingOnPaper
    end
  end
end
