class ProductType
  include Context

  #ProductType::Drawing.builder #set.map(&:field_name).join(" ")
  def self.build_tags(set)
    set.map{|f| [f.tags["kind"], f.tags["sub_kind"]]}.to_h
  end

  def self.build_name(set)
    name_set=[]
    set.each do |f|
      name_set << name_set(f)
    end
    name_set.join(" ")
  end

  def self.name_set(f)
    if f.tags["kind"] == 'material'
      "on #{f.field_name}"
    elsif f.tags["kind"] == 'leafing'
      "with #{f.field_name}"
    else
      f.field_name
    end
  end

  #Material::StandardMaterial.options
  #ProductType.product_set_builder(set_a: %w[production], product_sets: [%w[sericel], %w[drawing]], prepend_set: %w[original], append_set: ['with COA']) ::Original::Paintings.builder
  def self.product_set_builder(set_a:, product_sets:, prepend_set:[], append_set:[])
    product_set = set_a.product(*product_sets)
    product_set.each do |set|
      set = prepend_set.map {|v| set.prepend(v)}.flatten if prepend_set.any?
      set = append_set.map {|v| set.append(v)}.flatten if append_set.any?
      product(klass_name, build_name(set.flatten), set.flatten, build_tags(set.flatten))
    end
  end

  class Painting < ProductType
    def self.builder
      [
        product_set_builder(set_a: Category::Original.options, product_sets: [Medium::Paint.options, Material::StandardMaterial.options]),
        product_set_builder(set_a: Category::Original.options, product_sets: [Medium::PaperSpecificPaint.options, [Material::Paper.builder]])
      ]
    end
  end

  class Drawing < ProductType
    def self.builder
      [
        product_set_builder(set_a: Category::Original.options, product_sets: [Medium::DrawingMedia.options, [Material::Paper.builder]]),
        product_set_builder(set_a: Category::Original.options, product_sets: [Medium::BasicDrawingMedia.options, [Material::Paper.builder], [Medium::Leafing::GoldLeaf.builder, Medium::Leafing::SilverLeaf.builder]], prepend_set: [Medium::Embellishment::Colored.builder])
      ]
    end
  end

  class MixedMedia
  end

  class ProductionDrawing
  end

  class ProductionCel
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
