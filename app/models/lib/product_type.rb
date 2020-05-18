class ProductType
  include Context
  #ProductType::Original::Paintings.builder
  def self.build_name(set)
    set.map(&:field_name).join(" ")
  end
  #[[], [], []]
  class Original
    class Paintings
      def self.builder
        product_sets = Category::Original.options.product(Medium::Paint.options, Material::StandardMaterial.options)
        product_sets.each do |set|
          product = Painting.where(product_name: build_name(set)).first_or_create
          set.map{|opt| product.assoc_unless_included(opt)}
        end
      end

      def self.build_name(set)
        set.map(&:field_name).join(" ")
      end
    end

    class PaintingOnPaper
      def self.builder
        Category::Original.options.product(Medium::PaperSpecificPaint.options, [Material::Paper.builder])
      end
    end

    class Drawing
    end

    class MixedMediaDrawing
    end

    class ProductionDrawing
    end

    class ProductionCel
    end
  end



  # class Painting < ProductType
  #   def self.builder
  #     options.each do |option_set|
  #       option_set
  #     end
  #   end
  #
  #   def self.options
  #     [
  #       [[Category::Original.builder], [Medium::PaintMedia.builder], Material::StandardMaterial.options],
  #       [[Category::Original.builder], [Medium::PaperSpecificPaintMedia.builder], Material::Paper.builder]
  #     ]
  #   end
  #
  #   def self.filters
  #     options.map {|klass_set| [klass_set.first.search_hsh[:kind], klass_set.map{|klass| klass.search_hsh[:subkind]}]}
  #   end
  # end

  # class Drawing < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class MixedMedia < ProductType
  #   def self.builder
  #   end
  # end

  # class OneOfAKind < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class UniqueVariationPrint < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class LimitedEditionPrint < ProductType
  #   def self.builder
  #   end
  # end

  # class ProductionMedia < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class HandBlownGlass < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class HandMadeCeramic < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class LimitedEditionSculpture < ProductType
  #   def self.builder
  #   end
  # end
  #
  # class Sculpture < ProductType
  #   def self.builder
  #   end
  # end
  #
  # module ProductGroup
  #   def self.builder
  #   end
  # end
end
